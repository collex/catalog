require 'fileutils'

module Pages

   def get_eebo_subdir( image_id )
      # EEBO is split up int sub directories by what seems to be
      # wks_eebo_image_id. Pick a subdir based on this number.
      # NOTES: figured out these point by grep -nH :about *.rdf in each
      # directory of EEBO RDF. Noted the start and end numbers for each
      dir = ""
      if image_id <= 19199
         dir = "001"
      elsif image_id <= 52279
         dir = "002"
      elsif image_id <= 99357
         dir = "003"
      else
         dir = "004"
      end
      return dir
   end

   def add_pages_tag (archive, uri)
      cmd = "grep -R --include=*.rdf #{uri} #{RDF_PATH}/arc_rdf_#{archive}/ 2>/dev/null"

      # For EEBO, the above command is no good.. too much data in subdirectories. Search
      # takes too long. Insted, look at the image_id portion of the URI and determine which
      # subrirectory to confine the search to. See notes in the subdir method above.
      if archive.downcase == "eebo"
         image_id = uri.split("/").last.split("-").first.to_i
         dir = get_eebo_subdir(image_id)
         cmd = "grep -R --include=*.rdf #{uri} #{RDF_PATH}/arc_rdf_#{archive}/#{dir} 2>/dev/null"
      end

      result = `#{cmd}`
      if result.empty?
         print " ERROR: No RDF for work #{uri}"
         return false
      end

      # grep response is filename:hit. Get the filename
      id = uri.split("/").last
      rdf_file_name = result.split(":")[0]
      parser = LibXML::XML::Parser.file(rdf_file_name, :options => LibXML::XML::Parser::Options::NOBLANKS )
      rdf = parser.parse
      node = rdf.find_first("//recreate:collections[contains(@rdf:about,'#{id}')]")
      exist = node.find_first("//collex:pages")
      if exist.nil?
         # move existing RDF to a backup file
         new_name = rdf_file_name.gsub(/\.rdf$/i, ".ORIG_RDF")
         cmd = "mv #{rdf_file_name} #{new_name}"
         `#{cmd}`

         # add pages flag and write out new RDF
         node << LibXML::XML::Node.new('collex:pages', 'true')
         rdf.save(rdf_file_name, :indent => true)
      end

      return true
   end

   def pick_page_file(page_num, txt_path)
      base_path = File.split(txt_path)[0]
      # Preferences: x_ALTO.txt -> x_IDHMC.txt -> x.txt
      exts = ["_ALTO.txt", "_IDHMC.txt", ".txt"]
      exts.each do |ext|
         full = "#{base_path}/#{page_num}#{ext}"
         return full if File.exist? full
      end
      return txt_path
   end

   # Generate page data for an specific archive from the given batch_id.
   # If only pages for specific work are requested, tgt_work_id will
   # be non-nil. The uri_block is a block that determines URI for the
   # work, and fileame for the page-level RDF file for that work
   #
   def generate_pages(archive, batch_id, tgt_work_id, &uri_block)

      # Templae for page RDF header.
      hdr =
"<rdf:RDF xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"
         xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
         xmlns:collex=\"http://www.collex.org/schema#\"
         xmlns:recreate=\"http://www.collex.org/recreate_schema#\">
"

      # Template for each page in the page level RDF
      template =
"   <recreate:collections rdf:about=\"#URI#\">
       <collex:archive>pages_#{archive}</collex:archive>
       <collex:pageof>#FROM#</collex:pageof>
       <collex:text>#TXT#</collex:text>
       <collex:pagenum>#PAGE#</collex:pagenum>
    </recreate:collections>
"

      puts "Processing page results for batch #{batch_id}"
      page = 1
      works = {}
      emop_url = Rails.application.secrets.authentication['emop_root_url']
      api_token = Rails.application.secrets.authentication['emop_token']
      done = false
      cnt = 0
      begin
         # Get a block of page results from a batch...
         resp_str = RestClient.get "#{emop_url}/page_results?batch_id=#{batch_id}&page_size=100&page_num=#{page}",  :authorization => "Token #{api_token}"
         resp = JSON.parse(resp_str)
         total_pages = resp['total_pages'].to_i
         dot_increment = resp['total'].to_i/100
         done = (total_pages == page)
         resp['results'].each do | res |
            print "." if cnt % dot_increment
            cnt += 1

            # Main part we care about is the path to the OCR text file.
            # Parse it for key bits of info by splitting on '/'
            #   - last bit is filename and is always 'page_number.txt'
            #   - next to last bit is the work_id
            txt_path = res['ocr_text_path']
            bits = txt_path.split('/')
            work_id = bits[bits.length-2]
            txt_file = bits[bits.length-1]
            page_num = txt_file.split('.')[0]

            # If a specific work has been requested, skip all but it
            next if !tgt_work_id.nil? && tgt_work_id != work_id

            if !works.has_key? work_id
               # get work URI
               work_str = RestClient.get "#{emop_url}/works/#{work_id}",  :authorization => "Token #{api_token}"
               work_json = JSON.parse(work_str)['work']

               # Call the block that generates the URI and document name for this work
               # Block must return { :uri=>URL, :name=>RDF_NAME }
               info = yield work_json
               uri = info[:uri]
               rdf_name = info[:name]

               # update work rdf to include  <collex:pages>true</collex:pages>
               if !add_pages_tag(archive, uri)
                  # if this fails, skip it and flag this work so all other pages get skipped too
                  works[work_id] = { :error=>"NO_RDF" }
                  next
               end

               # Create RDF to stream page content entries for this work -
               # after ensuring that the the path to the file exists
               rdf_file = "#{RDF_PATH}/arc_rdf_pages_#{archive}/#{rdf_name}"
               path = File.split(rdf_file)[0]
               FileUtils.mkpath path
               File.open(rdf_file, "w") { |f| f.write(hdr) }

               # Stash this data in the works map so it can be reused for other pages in this work
               works[work_id] = {:uri=>uri, :rdf=>rdf_file}
            end

            # if there was a problem with this work, skip all pages from it
            work = works[work_id]
            next if !work[:error].nil?

            # read the page data
            page_txt_file = pick_page_file(page_num, txt_path)
            page_file = File.open(page_txt_file, "r")
            txt = page_file.read
            txt = txt.encode(:xml=>:text)

            # Generate RDF record for this page and tack it on the end of the work RDF file
            out = template.gsub(/#TXT#/, txt.gsub(/\n/, " "))
            out.gsub!(/#PAGE#/, page_num)
            out.gsub!(/#FROM#/, work[:uri])
            page_uri = String.new(work[:uri]) << "/" << page_num.rjust(4,"0")
            out.gsub!(/#URI#/, page_uri)

            # append results to file
            File.open(work[:rdf], "a+") { |f| f.write(out) }
         end
         page += 1
      end while done==false

      # Now run through all of the newly created page-RDF files (one per edition)
      # and close out the rdf:RDF tag
      # NOTE all of this is necessary because the data file from eMOP enterleaves
      # pages of editions
      works.each do |k,v|
         if v.has_key? :rdf
            File.open(v[:rdf], "a+") { |f| f.write("</rdf:RDF>") }
         end
      end
      puts "DONE"
   end
end