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

namespace :ecco do
	desc "Mark texts for typewright (param: file=/text/file/path/one/item/per/line)"
	task :typewright_enable => :environment do
		file = ENV['file']
		if file == nil
			puts "Usage: call with file=/text/file\nThe text file should have a list of 10-digit numbers, with one of them per line."
		else
			start_time = Time.now
			src = Solr.factory_create(:live)
			dst = Solr.new("archive_ECCO")
			has_dot = false
			num_added = 0
			num_missing = 0
			File.open(file).each_line{ |text|
				uri = "lib\\://ECCO/#{text.strip()}"
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
			puts "rake solr_index:merge_archive archive=ECCO"
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
			dst = Solr.new("archive_ECCO")
			has_dot = false
			num_added = 0
			num_missing = 0
			uris = uris.split('-')
			uris.each{ |text|
				uri = "lib\\://ECCO/#{text.strip()}"
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
			puts "rake solr_index:merge_archive archive=ECCO"
			finish_line(start_time)
		end
	end
end
