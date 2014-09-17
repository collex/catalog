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

  desc "Mark archive_EEBO texts for typewright (param: file=/text/file/path/one/item/per/line)"
  task :typewright_enable, [:file] => :environment do |t, args|

    file = args[:file]
    if file == nil
      puts "Usage: call with file=/text/file\nThe text file should have a list of EEBO uri's, with one of them per line."
    else
      start_time = Time.now
      dst = Solr.new("archive_EEBO")
      has_dot = false
      num_added = 0
      num_missing = 0
      count = 0
      File.open(file).each_line{ |text|
        uri = text.strip( )
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
      puts "rake solr_index:merge_archive archive=EEBO"
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
    hits = []
    process_eebo_entries(hits)
    puts("STATUS: sorting...")
    hits.sort! { |a,b| a['uri'] <=> b['uri'] }
    puts("STATUS: resolving source...")
    resolve_eebo_source(hits)

    block_size = 10000
    file_num = 1000
    while true

       remaining = [ hits.size, block_size ].min
       break if remaining == 0

       puts( "STATUS: processing fulltext...")
       puts "remaining = #{remaining}"
       block = hits[ 0, remaining ]
       process_eebo_fulltext( block )

       # use an EEBO prefix, max size 1MB, start at # 1000 and partition into subdirs
       file_num = RegenerateRdf.regenerate_all( block, "#{RDF_PATH}/arc_rdf_eebo", "EEBO", 1000000, file_num, true )

       while remaining != 0
         hits.delete_at( 0 )
         remaining -= 1
       end
    end
    finish_line(start_time)
  end

  def process_eebo_entries(hits, max_recs = 9999999)
#  def process_eebo_entries(hits, max_recs = 25000)

    filter_out = load_filter_list( )
    total_recs = 0
    Work.find_each do | work |
      if work.isEEBO?

        # ignore any items on the filter out list
        if filter_out.include?( work.wks_eebo_image_id.strip ) == true
          next
        end

        obj = {}

        # special fields used in the subsequent steps
        tokens = work.wks_eebo_directory.split( "/" )
        obj[ 'wks_marc_record' ] = work.wks_marc_record
        obj[ 'image_id' ] = tokens[ tokens.size - 1 ]
        obj[ 'eebo_dir' ] = tokens[ tokens.size - 2 ]

        obj[ 'archive' ] = "EEBO"
        obj[ 'federation' ] = "18thConnect"

        obj['uri'] = "lib://EEBO/#{sprintf( "%010d", work.wks_eebo_image_id )}-#{sprintf( "%010d", work.wks_eebo_citation_id)}"
        obj['url'] = "#{work.wks_eebo_url.gsub(/(.*):image:\d+$/, '\1')}:citation:#{work.wks_eebo_citation_id}"

        obj['title'] = work.wks_title
        obj['year'] = fix_date( work.wks_pub_date )
        obj['date_label'] = work.wks_pub_date

        obj['genre'] = "Citation"
        obj[ 'discipline'] = "Literature"
        obj[ 'doc_type'] = "Codex"

        obj['is_ocr'] = false
        obj['has_full_text'] = false
        obj['freeculture'] = false

        obj['role_AUT'] = work.wks_author
        obj['role_PBL'] = work.wks_publisher

        hits.push(obj)
        total_recs += 1
        puts("STATUS: processed: #{total_recs} ...") if total_recs % 500 == 0
        break if total_recs >= max_recs
      end
    end
    puts("Total: #{total_recs}")
  end

  def resolve_eebo_source( hits )

    meta = load_metadata( )
    hits.each { | obj |
      if meta[ obj[ 'image_id' ].to_i ].nil? == false
        obj[ 'source' ] = meta[ obj[ 'image_id' ].to_i ]
        #puts( "Resolved Id #{obj[ 'image_id' ]} to #{obj[ 'source' ]}")
      else
        puts "WARNING: cannot resolve source for image_id: #{obj[ 'image_id' ]}"
      end
    }
  end

  def load_metadata( )

    meta = {}
    filename = "eebo_metadata/extract.txt"
    image_ids = ''
    File.foreach(filename).with_index { |line, line_num|
      line = line.scrub( "?" )

      if line_num % 2 == 0
         image_ids = line[/<image_id>(.*)<\/image_id>/, 1]
         if image_ids.nil?
            puts ( "ERROR: unexpected line #{line_num} @ #{line}")
            return {}
         end
      else
        source = line[/<source>(.*)<\/source>/, 1]
        if source.nil?
          puts ( "ERROR: unexpected line #{line_num} @ #{line}")
          return {}
        end

        ids = image_ids.split( " " )
        ids.each { |id|
          meta[ id.to_i ] = source
        }
        image_ids = ''
      end
    }

    return( meta )
  end

  def process_eebo_fulltext( hits )

    hits.each { | obj |

      eebo_text_root = "/data/shared/text-xml/EEBO-TCP-document-text"
      #eebo_text_root = "/Users/daveg/Sandboxes/collex-catalog/tmp"

      # we have TCP text available...
      if obj[ 'wks_marc_record'].nil? == false && obj[ 'wks_marc_record'].empty? == false
        textfile = "#{eebo_text_root}/#{obj['eebo_dir']}/#{obj['image_id']}.txt"
        if File.exist?( textfile ) == true
          File.open( textfile, "r" ) { |f|
            obj[ 'text'] = f.read
          }
          obj[ 'has_full_text' ] = true
        else
          puts "WARNING: #{textfile} does not exist or not readable"
        end
      else
      end

      obj.delete( 'wks_marc_record' )
      obj.delete( 'image_id' )
      obj.delete( 'eebo_dir' )
    }
  end

  def load_filter_list

    filter_list = []
    filename = "eebo_metadata/filter.txt"
    File.foreach(filename) { |line|
      line.strip!
      filter_list.push( line )
    }
    return( filter_list )

  end

  def fix_date( date )

     tokens = date.split( "-" )
     if tokens.length == 2

        if tokens[ 0 ].length == 2
          date_out = "#{tokens[0]}00,#{tokens[1]}"
        elsif tokens[ 0 ].length == 0
          date_out = tokens[1]
        else
          date_out = "#{tokens[0]},#{tokens[1]}"
        end
     else
       date_out = date
     end

  end

end
