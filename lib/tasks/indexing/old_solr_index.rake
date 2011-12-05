# encoding: UTF-8
##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
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

namespace :xxx_solr_index do


	desc "Uses the current record and goes to the web site to refresh the fulltext field (param: p=core,uri)"
	task :refresh_text  => :environment do
		start_time = Time.now
		p = ENV['p']
		p2 = p.split(',')
		if p2.length != 2
			puts "Usage: pass p=core,uri to refresh the text of that uri in that index"
		else
			require "#{Rails.root}/script/lib/refresh_doc.rb"
			RefreshDoc.run({ :uri => p2[1], :verbose => true, :core => p2[0] })
		end
			finish_line(start_time)
	end

	desc "Creates an RDF with all available information from all objects in the specified archive (params: archive=ARCHIVE[,PATH])"
	task :recreate_rdf_from_index  => :environment do
		# This was created to get the UVA MARC records out of the index when we couldn't recreate the uva MARC records.
		archive = ENV['archive']
		if archive == nil
			puts "Usage: Pass in an archive name with archive=XXX; there should be a folder of the same name under #{RDF_PATH}, or the subfolder can be specified."
		else
			arr = archive.split(',')
			path = arr.length == 1 ? arr[0] : arr[1]
			archive = arr[0]
			puts "~~~~~~~~~~~ Recreating RDF for the #{archive} archive into #{RDF_PATH}/#{path} ..."
			start_time = Time.now
			resources= CollexEngine.new(['resources'])
			all_recs = resources.get_all_objects_in_archive_with_text(archive)
			RegenerateRdf.regenerate_all(all_recs, "#{RDF_PATH}/#{path}", archive)
			finish_line(start_time)
		end
	end

	desc "Get list of objects not reindexed (optional param: use_merged_index=true, archive=XXX)"
	task :scan_for_missed_objects => :environment do
		use_merged_index = ENV['use_merged_index']
		use_merged_index = (use_merged_index != nil && (use_merged_index == "true" || use_merged_index == true))
		archive = ENV['archive']
		puts "~~~~~~~~~~~ Scanning for missed documents #{archive ? "("+archive+" only) " : ""}in #{use_merged_index ? 'merged' : 'archive_*'} index..."
		start_time = Time.now
		CollexEngine.get_list_of_skipped_objects({ :use_merged_index => use_merged_index, :archive => archive, :log => "#{Rails.root}/log/#{CollexEngine.archive_to_core_name(archive)}_skipped.log" })
		finish_line(start_time)
	end
	

	def xxx_trans_str(str)
		ret = ""
		str.to_s.each_char(){ |ch|
			"#{ch}".each_byte { |c|
				if (c >= 32 && c <= 127) || c == 10
					ret += ch
				else
					ret += "~#{c}~"
				end
			}
		}
		return ret
	end

	desc "clear the reindexing index (param: index=[archive_*])"
	task :clear_reindexing_index  => :environment do
		index = ENV['index']
		if index == nil
			puts "Usage: call with index=XXX"
		else
			puts "~~~~~~~~~~~ Clearing reindexing index #{index}..."
			start_time = Time.now
			reindexed = CollexEngine.new([index])
			reindexed.clear_index()
			finish_line(start_time)
		end
	end

	desc "recreate the archive index as an exact copy of that archive in the resources (param: archive=XXX)"
	task :copy_resource_to_archive => :environment do
		archive = ENV['archive']
		if archive == nil
			puts "Usage: call with archive=XXX"
		else
			puts "~~~~~~~~~~~ Create archive #{archive} from resources..."
			start_time = Time.now
			folders = get_folders(RDF_PATH, archive)
			if folders[:error]
				puts folders[:error]
			else
				resources = CollexEngine.new()
				dst = CollexEngine.new(["archive_#{archive}"])
				hits = resources.get_all_objects_in_archive_with_text(archive)
				puts "Starting the copy"
				dst.clear_index()
				hits.each_with_index { |hit, i|
					if hit['is_ocr'] == nil
						if hit['text']
							hit['is_ocr'] = true
						else
							hit['is_ocr'] = false
						end
					end
					dst.add_object(hit)
					if i % 100 == 0
						print '.'
					end
				}
				dst.commit()
				finish_line(start_time)
			end
		end

	end


	desc "Tag all RDF, MARC, and ECCO in SVN (param: label=XXX)"
	task :tag_rdf_marc_and_ecco => :environment do
		version = ENV['label']
		if version == nil || version.length == 0
			puts "Usage: pass label=XXX to tag the current set of RDF, MARC, and ECCO records"
		else
			puts "Tagging version #{version}..."
			system("svn copy -rHEAD -m tag #{SVN_RDF}/trunk #{SVN_RDF}/tags/#{version}")
		end
	end

	desc "Get all the text from a particular archive and dump it in a series of text files"
	task :get_text_from_archive => :environment do
		archive = ENV['archive']
		if archive == nil || archive.length == 0
			puts "Usage: pass archive=XXX"
		else
			folders = get_folders(RDF_PATH, archive)
			if folders[:error]
				puts "The archive entry for \"#{archive}\" was not found in any sitemap.yml file."
			else
				page_size = folders[:pagesize].to_i
				arr = RDF_PATH.split('/')
				arr.pop()
				arr.push('fulltext')
				base_path = arr.join('/')
				folder = "#{base_path}/#{CollexEngine.archive_to_core_name(archive)}"
				puts "Dumping all text from archive #{archive} to #{folder}, page=#{page_size}..."
				safe_mkpath(folder)
				# TODO-PER: first remove all existing files from that folder
				index = CollexEngine.new()
				index.enumerate_all_recs_in_archive(archive, true, page_size) { |hit|
					hit['text_url'] = hit['text_url'][0] if hit['text_url'] && hit['text_url'].length > 0
					if hit['text'] && hit['text'].length > 0 && hit['text_url'] && hit['text_url'].length > 0
						fname = hit['text_url'].gsub('/', 'SL').gsub(':', 'CL').gsub('?', 'QU').gsub('=', 'EQ').gsub('&', 'AMP')
						if hit['text'].kind_of? String
							File.open("#{folder}/#{fname}.txt", 'w') {|f| f.write(hit['text'] ) }
						else
							File.open("#{folder}/#{fname}.txt", 'w') {|f| f.write(hit['text'].join("\n")) }
						end
					end
				}
			end
		end

	end
end
