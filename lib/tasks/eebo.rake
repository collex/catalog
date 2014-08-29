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
  desc "Mark texts for typewright (param: archive=EEBO file=/text/file/path/one/item/per/line  uri=lib://eebo/1234)"
  task :typewright_enable => :environment do

    file = ENV['file']
    uri = ENV['uri']
    archive = ENV['archive']
    if (file == nil and uri == nil) or archive == nil
      puts "Usage: call with archive=name with either file= or uri=\n" +
           "       file=/text/file\nThe text file should have a list of 10-digit numbers, with one of them per line."
    elsif uri != nil
      start_time = Time.now
      src = Solr.factory_create(:live)
      dst = Solr.new("archive_#{archive}")
      has_dot = false
      num_added = 0
      num_missing = 0
      begin
        obj = src.full_object(uri)
        obj['typewright'] = true
        dst.add_object(obj, false, false)
        print '.'
        has_dot = true
        num_added += 1
      rescue SolrException => e
        puts "" if has_dot
        has_dot = false
        puts e.to_s
        num_missing += 1
      end

      dst.commit()
      puts "\nNumber of documents added to typewright: #{num_added}"
      puts "Number of documents not found: #{num_missing}"
      puts "All items processed into the test index. If the test index looks correct, then merge it into the live index with:"
      puts "rake solr_index:merge_archive archive=#{archive}"
      finish_line(start_time)

    elsif file == nil
      start_time = Time.now
      src = Solr.factory_create(:live)
      dst = Solr.new("archive_#{archive}")
      has_dot = false
      num_added = 0
      num_missing = 0
      File.open(file).each_line{ |text|
        uri = "#{text.strip()}"
        begin
          obj = src.full_object(uri)
          obj['typewright'] = true
          dst.add_object(obj, false, false)
          print '.'
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
      puts "rake solr_index:merge_archive archive=#{archive}"
      finish_line(start_time)
    end
  end

  desc "Unmark texts for typewright (param: [0000000000-0000000001-0000000002])"
  task :typewright_disable, [:uris] => :environment  do |t, args|
    uris = args[:uris]
    if uris == nil
      puts "Usage: call with [0000000000-0000000001-0000000002]\nThe parameters are a list of 10-digit numbers, with dashes in between."
    else
      start_time = Time.now
      src = Solr.factory_create(:live)
      dst = Solr.new("archive_EEBO")
      has_dot = false
      num_added = 0
      num_missing = 0
      uris = uris.split('-')
      uris.each{ |text|
        uri = "lib\\://EEBO/#{text.strip()}"
        begin
          obj = src.full_object(uri)
          obj['typewright'] = false
          dst.add_object(obj, false, false)
          print '.'
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
      puts "\nNumber of documents removed from typewright: #{num_added}"
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
    puts("Processing...")
    hits = []
    process_eebo_entries(hits)
    puts("Sorting...")
    hits.sort! { |a,b| a['uri'] <=> b['uri'] }
    #puts("Processing fulltext...")
    #process_eebo_fulltext(hits)
    RegenerateRdf.regenerate_all(hits, "#{RDF_PATH}/arc_rdf_eebo", "EEBO", 500000)
    finish_line(start_time)
  end

  def process_eebo_entries(hits, max_recs = 9999999)
#  def process_eebo_entries(hits, max_recs = 2500)

    total_recs = 0
    Work.find_each do | work |
      if work.isEEBO?
        obj = {}
        obj[ 'archive' ] = "EEBO"
        obj[ 'federation' ] = "18thConnect"

        obj['url'] = work.wks_eebo_url
        #tokens = work.wks_eebo_url.split('&')
        eebo_id = "lib://EEBO/#{"%010d" % work.wks_work_id}"
        obj['uri'] = eebo_id

        obj['title'] = work.wks_title
        obj['year'] = work.wks_pub_date.gsub( "-","," )
        obj['date_label'] = work.wks_pub_date

        obj['genre'] = "Citation"
        obj[ 'discipline'] = "Literature"
        obj[ 'doc_type'] = "Codex"

        obj['is_ocr'] = false
        obj['has_full_text'] = false
        obj['freeculture'] = false

        obj['role_AUT'] = work.wks_author
        obj['role_PBL'] = work.wks_publisher

        #obj['text'] = ""
        obj['has_full_text'] = false

        hits.push(obj)
        total_recs += 1
        #puts( "Year: #{obj['year']}, label: #{obj['date_label']}") if obj['year'] != obj['date_label' ]
        puts("Processed: #{total_recs} ...") if total_recs % 500 == 0
        break if total_recs >= max_recs
      end
    end
    puts("Total: #{total_recs}")

  end

end
