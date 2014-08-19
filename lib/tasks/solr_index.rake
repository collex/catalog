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

require 'fileutils'
require "#{Rails.root}/lib/tasks/task_reporter.rb"
require "#{Rails.root}/lib/tasks/task_utilities.rb"

namespace :solr_index do
	include TaskUtilities

	def get_folders(path, archive)
		folder_file = File.join(path, "sitemap.yml")
		site_map = YAML.load_file(folder_file)
		rdf_folders = site_map['archives']
		all_enum_archives = {}
		rdf_folders.each { |k, f|
			if f.kind_of?(String)
				all_enum_archives[k] = f
			else
				all_enum_archives.merge!(f)
			end
		}
		folders = all_enum_archives[archive]
		if folders == nil
			return {:error => "The archive \"#{archive}\" was not found in #{folder_file}"}
		end
		return {:folders => folders[0].split(';'), :page_size => folders[1]}
	end

	desc "create complete reindexing task list"
	task :create_reindexing_task_list => :environment do
		#solr = CollexEngine.factory_create(false)
		#archives = solr.get_all_archives()

		folder_file = File.join(RDF_PATH, "sitemap.yml")
		site_map = YAML.load_file(folder_file)
		rdf_folders = site_map['archives']
		sh_all = create_sh_file("batch_all")
		sh_all.puts("TASK=solr_index:index_and_test\n")

		# the archives found need to exactly match the archives in the site maps.
		all_enum_archives = {}
		rdf_folders.each { |k,f|
			all_enum_archives.merge!(f)
		}
		#all_enum_archives.merge!(marc_folders)
		#archives.each {|archive|
		#	if archive.index("exhibit_") != 0 && archive != "ECCO" && all_enum_archives[archive] == nil
		#		puts "Missing archive #{archive} from the sitemap.yml files"
		#	end
		#}
		#all_enum_archives.each {|k,v|
		#	if !archives.include?(k)
		#		puts "Archive #{k} in sitemap missing from deployed index"
		#	end
		#}

		sh_clr = create_sh_file("clear_archives")
		#core_archives = CollexEngine.get_archive_core_list()
		#core_archives.each {|archive|
		#}
		sh_merge = create_sh_file("merge_all")
		merge_list = []

		rdf_folders.each { |i, rdfs|
			if i.kind_of?(Fixnum)
				sh_rdf = create_sh_file("batch#{i+1}")
				sh_rdf.puts("TASK=solr_index:index_and_test\n")
				merge_list_section = []
				rdfs.each {|archive,f|
					sh_clr.puts("curl #{SOLR_URL}/#{archive}/update?stream.body=%3Cdelete%3E%3Cquery%3E*:*%3C/query%3E%3C/delete%3E\n")
					sh_clr.puts("curl #{SOLR_URL}/#{archive}/update?stream.body=%3Ccommit%3E%3C/commit%3E\n")

					sh_rdf.puts("rake \"archive=#{archive}\" $TASK\n")
					sh_all.puts("rake \"archive=#{archive}\" $TASK\n")

					merge_list.push(archive)
					merge_list_section.push(archive)
					#if merge_list.length > 10
					#	sh_merge.puts("rake solr_index:merge_archive archive=\"#{merge_list.join(',')}\"")
					#	merge_list = []
					#end
				}
				sh_rdf.close()
				sh_merge_list_section = create_sh_file("merge#{i+1}")
				sh_merge_list_section.puts("rake solr_index:merge_archive archive=\"#{merge_list_section.join(',')}\"")
				sh_merge_list_section.close()
			end
		}
		sh_clr.close()
		if merge_list.length > 0
			sh_merge.puts("rake solr_index:merge_archive archive=\"#{merge_list.join(',')}\"")
		end
		sh_merge.puts("rake solr:optimize core=resources")
		sh_merge.close()

#		sh_all.puts("rake ecco:mark_for_textwright\n")

		sh_all.close()
	end

	def index_archive(msg, archive, type)
		flags = nil
		case type
			when :spider
				flags = "-mode spider"
				puts "~~~~~~~~~~~ #{msg} \"#{archive}\" [see log/progress/#{archive}_progress.log and log/#{archive}_spider_error.log]"
			when :index
				flags = "-mode index -delete"
				puts "~~~~~~~~~~~ #{msg} \"#{archive}\" [see log/progress/#{archive}_progress.log and log/#{archive}_error.log]"
			when :debug
				flags = "-mode test"
				puts "~~~~~~~~~~~ #{msg} \"#{archive}\" [see log/progress/#{archive}_progress.log and log/#{archive}_error.log]"
		end

		if flags == nil
			puts "Call with either :spider, :index or :debug"
		else
			folders = get_folders(RDF_PATH, archive)
			if folders[:error]
				puts folders[:error]
			else
				safe_name = Solr::archive_to_core_name(archive)
				log_dir = "#{Rails.root}/log"
				case type
					when :spider
						delete_file("#{log_dir}/#{safe_name}_spider_error.log")
					when :index, :debug
						delete_file("#{log_dir}/#{safe_name}_error.log")
				end
				delete_file("#{log_dir}/progress/#{safe_name}_progress.log")
				delete_file("#{log_dir}/#{safe_name}_error.log")
				delete_file("#{log_dir}/#{safe_name}_link_data.log")
				delete_file("#{log_dir}/#{safe_name}_duplicates.log")

				folders[:folders].each { |folder|
					cmd_line("cd #{indexer_path()} && java -Xmx3584m -jar #{indexer_name()} -logDir \"#{log_dir}\" -source \"#{RDF_PATH}/#{folder}\" -archive \"#{archive}\" #{flags}")
				}
			end
		end
	end

	def compare_indexes_java (archive, page_size = 500, mode = nil)

		flags = ""
		safe_name = Solr::archive_to_core_name(archive)
		log_dir = "#{Rails.root}/log/index"

		# no mode specified = full compare on al fields.
		# delete all log files
		if mode.nil?
			delete_file("#{log_dir}/#{safe_name}_compare.log")
			delete_file("#{log_dir}/#{safe_name}_compare_text.log")
		else
			# if just txt compare is requested, ony delete txt log
			if mode == "compareTxt"
				flags = "-include text"
				delete_file("#{log_dir}/#{safe_name}_compare_text.log")
			end

			# if non-txt compare is requested, only delete the compare log
			if mode == "compare"
				flags = "-ignore text"
				delete_file("#{log_dir}/#{safe_name}_compare.log")
			end
		end

		# skipped is always deleted
		delete_file("#{log_dir}/#{safe_name}_skipped.log")

		# launch the tool
		cmd_line("cd #{indexer_path()} && java -Xmx3584m -jar #{indexer_name()} -logDir \"#{log_dir}\" -archive \"#{archive}\" -mode compare #{flags} -pageSize #{page_size}")

	end

	def test_archive(archive)
		puts "~~~~~~~~~~~ testing \"#{archive}\" [see log/#{archive}_*.log]"
		folders = get_folders(RDF_PATH, archive)
		if folders[:error]
			puts "The archive entry for \"#{archive}\" was not found in any sitemap.yml file."
		else
				folders[:folders].each {|folder|
					find_duplicate_uri(folder, archive)
				}

			page_size = folders[:page_size].to_s
			compare_indexes_java(archive, page_size)
		end
	end

	def do_archive(split = :split)
		archive = ENV['archive']
		if archive == nil
			puts "Usage: call with archive=XXX,YYY"
		else
			start_time = Time.now
			if split == :split
				archives = archive.split(',')
				archives.each { |a| yield a }
			else
				yield archive
			end
			finish_line(start_time)
		end
	end

	def find_duplicate_uri(folder, archive)
		puts "~~~~~~~~~~~ Searching for duplicates in \"#{RDF_PATH}/#{folder}\" ..."
		puts "creating folder list..."
		directories = get_folder_tree("#{RDF_PATH}/#{folder}", [])

		directories.each { |dir|
			TaskReporter.set_report_file("#{Rails.root}/log/#{Solr.archive_to_core_name(archive)}_duplicates.log")
			puts "scanning #{dir} ..."
			all_objects_raw = `find #{dir}/* -maxdepth 0 -print0 | xargs -0 grep "rdf:about"` # just do one folder at a time so that grep isn't overwhelmed.
			all_objects_raw = all_objects_raw.split("\n")
			all_objects = {}
			all_objects_raw.each { |obj|
				arr = obj.split(':', 2)
				arr1 = obj.split('rdf:about="', 2)
				arr2 = arr1[1].split('"')
				if all_objects[arr2[0]] == nil
					all_objects[arr2[0]] = arr[0]
				else
					TaskReporter.report_line("Duplicate: #{arr2[0]} in #{all_objects[arr2[0]]} and #{arr[0]}")
				end
			}
		}
	end

	def merge_archive(archive)
		puts "~~~~~~~~~~~ Merging archive(s) #{archive} ..."
		archives = archive.split(',')
		solr = Solr.factory_create(:live)
		archive_list = []
		archives.each{|arch|
			index_name = Solr.archive_to_core_name(arch)
			solr.remove_archive(arch, false)
			archive_list.push("archive_#{index_name}")
		}
		solr.merge_archives(archive_list)

	end

	#############################################################
	## TASKS
	#############################################################

	desc "Look for duplicate objects in rdf folders (param: folder=subfolder_under_rdf,archive)"
	task :find_duplicate_objects => :environment do
		folder = ENV['folder']
		arr = folder.split(',') if folder
		if arr == nil || arr.length != 2
			puts "Usage: call with folder=folder,archive"
		else
			folder = arr[0]
			archive = arr[1]
			start_time = Time.now
			find_duplicate_uri(folder, archive)
			finish_line(start_time)
		end
	end

	desc "Index documents from the rdf folder to the reindex core (param: archive=XXX,YYY)"
	task :index  => :environment do
		do_archive { |archive| index_archive("Index", archive, :index) }
	end

	desc "Test one RDF archive (param: archive=XXX,YYY)"
	task :archive_test => :environment do
		do_archive { |archive| test_archive(archive) }
	end

	desc "Do the initial indexing of a folder to the archive_* core (param: archive=XXX,YYY)"
	task :debug => :environment do
		do_archive { |archive| index_archive("Debug", archive, :debug) }
	end

	desc "Index and test one rdf archive (param: archive=XXX,YYY)"
	task :index_and_test => :environment do
		do_archive { |archive|
			index_archive("Index", archive, :index)
			test_archive(archive)
		}
	end

	desc "Spider the archive for the full text and place results in rawtext. No indexing performed. (param: archive=XXX,YYY)"
	task :spider_rdf_text => :environment do
		do_archive { |archive| index_archive("Spider text", archive, :spider) }
	end

	desc "Merge one archive into the \"resources\" index (param: archive=XXX,YYY)"
	task :merge_archive => :environment do
		do_archive(:as_one) { |archives| merge_archive(archives) }
	end

	desc "Package an individual archive and send it to a server. (archive=XXX,YYY) This gets it ready to be installed on the other server with the sister script: solr:install"
	task :package => :environment do
		do_archive { |archive|
      if "#{archive}" == "EEBO" or "#{archive}" == "TEST_RDF"
        puts "Archive #{archive} is a test archive and is not ready to be packaged."
      else
        index = "archive_#{archive}"
        filename = backup_archive(index)
        case Rails.application.secrets.folders['tasks_send_method']
        when 'cp'
          FileUtils.cp(filename, dest_filename_of_zipped_index(index))
        else
          Net::SCP.start(Rails.application.secrets.production['ssh_host'], Rails.application.secrets.production['ssh_user']) do |scp|
            scp.upload! filename, dest_filename_of_zipped_index(index)
          end
        end
      end
		}
	end

	desc "Package the main archive and send it to a server. (archive=XXX,YYY) This gets it ready to be installed on the other server with the sister script: solr:install"
	task :package_resources => :environment do
		filename = backup_archive('resources')
    case Rails.application.secrets.folders['tasks_send_method']
    when 'cp'
      FileUtils.cp(filename, dest_filename_of_zipped_index('resources'))
    else
      Net::SCP.start(Rails.application.secrets.production['ssh_host'], Rails.application.secrets.production['ssh_user']) do |scp|
        scp.upload! filename, dest_filename_of_zipped_index('resources')
      end
    end
	end

	desc "This assumes a list of gzipped archives in the #{Rails.application.secrets.folders['uploaded_data']} folder named like this: archive_XXX.tar.gz. (params: archive=XXX,YYY) It will add those archives to the resources index."
	task :install => :environment do
		indexes = []
		solr = Solr.factory_create(:live)
		do_archive { |archive|
			folder = Rails.application.secrets.folders['uploaded_data']
			index = "archive_#{archive}"
			index_path = "#{folder}/#{index}"
			indexes.push(index_path)
			cmd_line("cd #{folder} && tar xvfz #{index}.tar.gz")
			cmd_line("rm -r -f #{index_path}")
			cmd_line("mv #{uploaded_data_index} #{index_path}")
			File.open("#{Rails.root}/log/archive_installations.log", 'a') {|f| f.write("Installed: #{Time.now().getlocal().strftime("%b %d, %Y %I:%M%p")} Created: #{File.mtime(index_path).getlocal().strftime("%b %d, %Y %I:%M%p")} #{archive}\n") }
			solr.remove_archive(archive, false)
		}

		if indexes.length > 0
			# delete the cache
			delete_file("#{Rails.root}/cache/num_docs.txt")

			solr.merge_archives(indexes, false)
			solr.commit()
		end
	end

	desc "removes the archive from the resources index (param: archive=XXX,YYY)"
	task :remove  => :environment do
		solr = Solr.factory_create(:live)
		do_archive { |archive|
			solr.remove_archive(archive, false)
		}
		if !solr.blank?
			solr.commit()
			solr.optimize()
		end
	end

	desc "removes all exhibits from the resources index"
	task :delete_exhibits => :environment do
		solr = Solr.factory_create(:live)
		archives = solr.get_archive_list()
		archives.each { |archive|
			if archive.index('exhibit_') == 0
				puts archive
				solr.remove_archive(archive, false)
			end
		}
		solr.commit()
		solr.optimize()
	end

	#def clean_text(msg, archive, type, encoding)
	#	start_time = Time.now
	#	flags = nil
	#	dir_name = nil
	#	case type
	#		when :clean_raw
	#			flags = "-mode clean_raw -encoding #{encoding}" if encoding != nil
	#			flags = "-mode clean_raw" if encoding == nil
	#			dir_name = "rawtext"
	#			puts "~~~~~~~~~~~ #{msg} \"#{archive}\" [see log/progress/#{archive}_progress.log and log/#{archive}_clean_raw_error.log]"
	#		when :clean_full
	#			flags = "-mode clean_full"
	#			dir_name = "fulltext"
	#			puts "~~~~~~~~~~~ #{msg} \"#{archive}\" [see log/progress/#{archive}_progress.log and log/#{archive}_clean_full_error.log]"
	#	end
	#
	#	if flags == nil
	#		puts "Call with either :clean_raw or :clean_full"
	#	else
	#
	#		# determine path to text files for cleaning
	#		arr = RDF_PATH.split('/')
	#		arr.pop()
	#		arr.push(dir_name)
	#		text_path = arr.join('/')
	#
	#		# clear out old log files
	#		safe_name = Solr::archive_to_core_name(archive)
	#		log_dir = "#{Rails.root}/log"
	#		case type
	#			when :clean_raw
	#				delete_file("#{log_dir}/#{safe_name}_clean_raw_error.log")
	#			when :clean_full
	#				delete_file("#{log_dir}/#{safe_name}_clean_full_error.log")
	#		end
	#		delete_file("#{log_dir}/#{safe_name}_progress.log")
	#		delete_file("#{log_dir}/#{safe_name}_error.log")
	#
	#		cmd_line("cd #{indexer_path()} && java -Xmx3584m -jar #{indexer_name()} -logDir \"#{log_dir}\" -source #{text_path} -archive \"#{archive}\" #{flags}")
	#
	#	end
	#	finish_line(start_time)
	#end

	desc "Clean archive text and place results in fulltext, ready for indexing; No indexing performed; (param: archive=XXX,YYY)"
	task :clean_text => :environment do
		do_archive { |archive|
			safe_name = Solr::archive_to_core_name(archive)
			log_dir = "#{Rails.root}/log"
			delete_file("#{log_dir}/progress/#{safe_name}_progress.log")
			delete_file("#{log_dir}/#{safe_name}_clean_raw_error.log")
			case archive
				when 'cali'
					source = 'fulltext'
					mode = 'clean_full'
					custom = '-custom CaliCleaner'
				when 'locEphemera'
					source = 'rawtext'
					mode = 'clean_raw'
					custom = '-custom LocEphemeraCleaner'
				when 'ncaw'
					source = 'rawtext'
					mode = 'clean_raw'
					custom = '-custom NcawCleaner'
				when 'nineteen'
					source = 'rawtext'
					mode = 'clean_raw'
					custom = '-custom NineteenCleaner'
				when 'WrightAmFic'
					source = 'rawtext'
					mode = 'clean_raw'
					custom = '-custom WrightAmFicCleaner'
        when 'walters'
          source = 'rawtext'
          mode = 'clean_raw'
          custom = ''
				else
					puts "WARNING: No custom text cleaning was defined for this archive!"
					source = 'rawtext'
					mode = 'clean_raw'
					custom = ''
			end
			cmd_line("cd #{indexer_path()} && java -Xmx3584m -jar #{indexer_name()} -logDir \"#{log_dir}\" -source #{RDF_PATH}/../#{source} -archive \"#{archive}\" -mode #{mode} #{custom}")
		}
	end

	desc "Create git repositories for all archives"
	task :create_git_repositories => :environment do
		return # don't accidentally call this -- this should have just been done once.
		folder_file = File.join(RDF_PATH, "sitemap.yml")
		site_map = YAML.load_file(folder_file)
		rdf_folders = site_map['archives']
		rdf_folders.each { |i, rdfs|
			if i.kind_of?(Fixnum)
				rdfs.each {|archive,f|
					# create project
					response = `curl -d "private_token=#{TAMU_KEY}&name=arc_rdf_#{archive}" https://gitlab.tamu.edu/api/v2/projects`
					puts response
					response = JSON.parse(response)
					project_id = response['id']

					if project_id.present?
						# add users
						user_list = [ 16, 18 ] # adam, dana
						user_list.each { |user|
							response = `curl -d "private_token=#{TAMU_KEY}&user_id=#{user}&access_level=40" https://gitlab.tamu.edu/api/v2/projects/#{project_id}/members`
							puts response
						}
					end
			}
			end
		}
	end

end
