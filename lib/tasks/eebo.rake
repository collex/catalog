# encoding: UTF-8
##########################################################################
# Copyright 2011 Applied Research in Patacriticism and the University of Virginia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

namespace :eebo do
   include Pages

   desc "Generate page-level RDF (params: archive, batch_id, work_id (optional), skip=y/N (optional - don't add pages flag to origninal rdf) )"
   task :generate_page_rdf => :environment do
      archive = ENV['archve']
      batch_id = ENV['batch_id']
      tgt_work = ENV['work_id']
      skip = ENV['skip']
      raise "batch_id is required!" if batch_id.nil?
      generate_pages(archive, batch_id, tgt_work, skip) { |work_json|
         last = work_json['wks_eebo_citation_id'].to_s.rjust(10, "0")
         image_id = work_json['wks_eebo_image_id'].to_i
         first = work_json['wks_eebo_image_id'].rjust(10, "0")
         unique = "#{first}-#{last}"
         uri = "lib://EEBO/#{unique}"

         out = { :uri=>uri, :name=>"#{unique}.rdf", :image_id=>image_id }
         out
      }
   end
   
   desc "close rdf tag on broken archives"
   task :close_rdf_tag => :environment do
      archive = ENV['archive']
      raise "archive is required!" if archive.nil?


      rdf_dir= "#{RDF_PATH}/arc_rdf_#{archive}"
      Dir.chdir( rdf_dir )
      Dir.glob("*.rdf") do |f|
         cmd = "grep '</rdf:RDF>' #{File.join(Dir.pwd, f)} 2>/dev/null"
         result = `#{cmd}`
         if result.empty?
            File.open(f, "a+") { |f| f.write("</rdf:RDF>") }
         end
      end
   end


  desc "Mark archive_EEBO texts for typewright (param: file=/text/file/path/one/item/per/line)"
  task :typewright_enable, [:file] => :environment do |t, args|

    file = ENV['file']
    if file == nil
      puts "Usage: call with file=/text/file\nThe text file should have a list of EEBO uri's, with one of them per line."
    else
      start_time = Time.now
      dst = Solr.new("archive_eebo_prq")
      has_dot = false
      num_added = 0
      num_missing = 0
      count = 0
      File.open(file).each_line{ |text|
        uri = "lib\\://EEBO/#{text.strip()}"
        begin
          print "\n#{count}" if count % 1000 == 0
          print '.' if count % 50 == 0
          count += 1

          obj = dst.full_object(uri)
          obj['typewright'] = true
          dst.add_object(obj, false, false)
          has_dot = true
          num_added += 1
        rescue SolrException => e
          puts "" if has_dot
          has_dot = false
          puts e.to_s
          num_missing += 1
        end
      }

      dst.commit()
      puts "\nNumber of documents added to typewright: #{num_added}"
      puts "Number of documents not found: #{num_missing}"
      puts "All items processed into the test index. If the test index looks correct, then merge it into the live index with:"
      puts "rake solr_index:merge_archive archive=eebo_prq"
      finish_line(start_time)
    end
  end

  desc "Unmark archive_EEBO texts for typewright (param: file=/text/file/path/one/item/per/line)"
  task :typewright_disable, [:file] => :environment  do |t, args|

    file = args[:file]
    if file == nil
      puts "Usage: call with file=/text/file\nThe text file should have a list of EEBO uri's, with one of them per line."
    else
      start_time = Time.now
      dst = Solr.new("archive_EEBO")
      has_dot = false
      num_removed = 0
      num_missing = 0
      count = 0
      File.open(file).each_line{ |text|
        uri = text.strip( )
        begin
          print "\n#{count}" if count % 1000 == 0
          print '.' if count % 50 == 0
          count += 1

          obj = dst.full_object(uri)
          obj['typewright'] = false
          dst.add_object(obj, false, false)
          has_dot = true
          num_removed += 1
        rescue SolrException => e
          puts "" if has_dot
          has_dot = false
          puts e.to_s
          num_missing += 1
        end
      }

      dst.commit()
      puts "\nNumber of documents renmoved from typewright: #{num_removed}"
      puts "Number of documents not found: #{num_missing}"
      puts "All items processed into the test index. If the test index looks correct, then merge it into the live index with:"
      puts "rake solr_index:merge_archive archive=EEBO"
      finish_line(start_time)
    end
  end

   desc "Create all the RDF files for EEBO documents, using eMOP database records."
   task :create_rdf => :environment do
      start_time = Time.now
      TaskReporter.set_report_file("#{Rails.root}/log/eebo_error.log")
      puts("STATUS: processing...")
      emop_url = Rails.application.secrets.authentication['emop_root_url']
      api_token = Rails.application.secrets.authentication['emop_token']

      # RDF Header block
      hdr =
 "<rdf:RDF xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"
      xmlns:role=\"http://www.loc.gov/loc.terms/relators/\"
      xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
      xmlns:dc=\"http://purl.org/dc/elements/1.1/\"
      xmlns:dcterms=\"http://purl.org/dc/terms/\"
      xmlns:collex=\"http://www.collex.org/schema#\"
      xmlns:recreate=\"http://www.collex.org/recreate_schema#\">
"
      # Template for each entry in the RDF file
      template =
"   <recreate:collections rdf:about=\"$URI\">
       <collex:archive>EEBO</collex:archive>
       <collex:freeculture>false</collex:freeculture>
       <collex:fulltext>false</collex:fulltext>
       <collex:ocr>false</collex:ocr>
       <collex:genre>Citation</collex:genre>
       <dc:title>$TITLE</dc:title>
       <role:AUT>$AUTHOR</role:AUT>
       <collex:federation>18thConnect</collex:federation>
       <role:PBL>$PUBLISHER</role:PBL>
       <dc:date>
          <collex:date>
             <rdfs:label>$DATE</rdfs:label>
             <rdf:value>$DATE</rdf:value>
          </collex:date>
       </dc:date>
       <rdfs:seeAlso rdf:resource=\"$URL\"/>
       <dc:source>$SOURCE</dc:source>
       <dc:type>Codex</dc:type>
       <collex:discipline>Literature</collex:discipline>
   </recreate:collections>
"

      meta = load_metadata()
      cnt = 0
      page = 1
      rdf_file = nil
      file_num_base = 1000
      file_cnt = 0
      len = 0
      max_len = 1000000
      dot_increment = 1000
      begin
         # Get a block of WORKs...
         resp_str = RestClient.get "#{emop_url}/works?per_page=1000&page_num=#{page}&is_eebo=true",  :authorization => "Token #{api_token}"
         resp = JSON.parse(resp_str)
         break if resp['results'].length == 0

         resp['results'].each do | res |
            print "." if cnt % dot_increment == 0
            cnt += 1

            # Skip all non-eebo
            next if res['wks_eebo_image_id'].nil?

            # Generate the URI
            image_id = res['wks_eebo_image_id']
            if image_id.nil?
               puts "SKIPPING BAD RECORD: #{res}"
               next
            end
            last = res['wks_eebo_citation_id'].to_s.rjust(10, "0")
            first = image_id.rjust(10, "0")
            unique = "#{first}-#{last}"
            uri = "lib://EEBO/#{unique}"
            url = "#{res['wks_eebo_url'].gsub(/(.*):image:\d+$/, '\1')}:citation:#{res['wks_eebo_citation_id']}"
            url.gsub!(/&/, "&amp;")
            title = res['wks_title'].gsub(/&/, "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
            pub = res['wks_publisher'].gsub(/&/, "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
            author = res['wks_author'].gsub(/&/, "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")


            # Extract source info from meta data file
            source = ""
            if meta[ image_id.to_i ].nil? == false
               source = meta[ image_id.to_i ].gsub(/&/, "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
            else
               puts "WARNING: cannot resolve source for image_id: #{res['wks_eebo_image_id']}"
            end

            # Fill out the RDF rec template
            rdf_rec = template.gsub(/\$URI/, uri)
            rdf_rec.gsub!(/\$TITLE/, title)
            rdf_rec.gsub!(/\$AUTHOR/, author)
            rdf_rec.gsub!(/\$PUBLISHER/, pub)
            rdf_rec.gsub!(/\$DATE/, res['wks_pub_date'])
            rdf_rec.gsub!(/\$URL/, url)
            rdf_rec.gsub!(/\$SOURCE/, source)

            # create file if necessary and reset all partitioning counters
            if rdf_file.nil? || len >= max_len

               # before creating a new one, close out the prior
               if !rdf_file.nil?
                  rdf_file.write("</rdf:RDF>")
                  rdf_file.close
               end

               file_name = "#{RDF_PATH}/arc_rdf_eebo/EEBO_#{file_num_base+file_cnt}.rdf"
               path = File.split(file_name)[0]
               FileUtils.mkpath path
               rdf_file = File.open(file_name, "w")
               rdf_file.write hdr
               len = hdr.length

               file_cnt = file_cnt+1
            end

            rdf_file.write rdf_rec
            len+= rdf_rec.length
         end
         page += 1
      end while true

      if !rdf_file.nil?
         rdf_file.write("</rdf:RDF>")
         rdf_file.close
      end
   end

   def load_metadata( )
      meta = {}
      filename = "eebo_metadata/extract.txt"
      image_ids = ''
      File.foreach(filename).with_index do |line, line_num|
         line = line.scrub( "?" )

         if line_num % 2 == 0
            image_ids = line[/<image_id>(.*)<\/image_id>/, 1]
            if image_ids.nil?
               puts "ERROR: unexpected line #{line_num} @ #{line}"
               return {}
            end
         else
            source = line[/<source>(.*)<\/source>/, 1]
            if source.nil?
               puts "ERROR: unexpected line #{line_num} @ #{line}"
               return {}
            end

            ids = image_ids.split( " " )
            ids.each { |id|
               meta[ id.to_i ] = source
            }
            image_ids = ''
         end
      end

      return meta
   end

end
