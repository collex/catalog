namespace :solr do
	def cmd_line(str)
		puts str
		puts `#{str}`
	end

	def get_solr_port
		arr = SOLR_URL.split('/')
		arr.each { |str|
			if str.index('localhost:')
				arr2 = str.split(':')
				return arr2[1]
			end
		}
		return '0000'
	end

	desc "Start the solr java app (Prerequisite for running CollexCatalog) [param: size=big if indexing something large]"
	task :start  => :environment do
		sz = ENV["size"]
		if sz && sz == 'big'
			sz = "5120"
		else
			sz = "2560"
		end
		port = get_solr_port()
		puts "~~~~~~~~~~~ Starting solr on #{port}..."
		cmd_line("cd #{SOLR_PATH} && java -Djetty.port=#{port} -DSTOP.PORT=8079 -DSTOP.KEY=c0113x -Xmx#{sz}m -jar start.jar 2> #{Rails.root}/log/solr.log &")
	end

	desc "Stop the solr java app"
	task :stop  => :environment do
		puts "~~~~~~~~~~~ Stopping solr..."
		port = get_solr_port()
		cmd_line("cd #{SOLR_PATH} && java -Djetty.port=#{port} -DSTOP.PORT=8079 -DSTOP.KEY=c0113x -jar start.jar --stop")
		puts "Finished."
	end

	def dump_hit(label, hit)
		puts " ------------------------------------------------ #{label} ------------------------------------------------------------------"
		hit.each { |key,val|
			if val.kind_of?(Array)
				val.each{ |v|
					#puts "#{key}: #{trans_str(v)}"
					if key == 'text'
						v = v.force_encoding("UTF-8")
					end
					puts "#{key}: #{v}"
				}
			else
				#puts "#{key}: #{trans_str(val)}"
				if key == 'text'
					val = val.force_encoding("UTF-8")
				end
				puts "#{key}: #{val}"
			end
		}
	end

	desc "examine solr document, both in the regular index and the reindexing index (param: uri)"
	task :examine  => :environment do
		uri = ENV['uri']
		solr = Solr.factory_create(:live)
		begin
			hit = solr.details({ 'q' => "uri:#{uri}" }, { :field_list => [] })
		rescue SolrException => e
			puts "Error: #{e}"
		end
		dump_hit("RESOURCES", hit)

#			archive = "archive_#{CollexEngine.archive_to_core_name(hit['archive'])}"
#			solr = Solr.new([archive])
#			hit = solr.get_object_with_text(uri)
#			if hit == nil
#				puts "#{uri}: Can't find this object in the archive."
#			else
#				dump_hit("ARCHIVE", hit)
#			end
#		end
	end

	desc "Optimize the index passed in [core=XXX]"
	task :optimize => :environment do
		core = ENV['core']
		if core == nil
			puts "Usage: pass in core=XXX"
		else
			puts "~~~~~~~~~~~ Optimize #{core}..."
			start_time = Time.now
			index = Solr.new(core)
			index.commit()
			index.optimize()
			finish_line(start_time)
		end
	end

	def filename_of_zipped_index(archive)
		today = Time.now()
		return "~/backups/#{archive}.#{today.strftime('20%y.%m.%d')}.tar.gz"
	end

	def dest_filename_of_zipped_index(archive)
		return "~/backups/#{archive}.tar.gz"
	end

	def backup_archive(archive)
		filename = filename_of_zipped_index(archive)
		puts "zipping index \"#{archive}\"..."
		cmd_line("cd #{SOLR_PATH}/solr/data/#{archive} && tar cvzf #{filename} index")
		return filename
	end

	desc "Backup the solr index specified. Leave a tar file in the backups folder. (param: index=XXX) [i.e. index=archive_rossetti]"
	task :backup => :environment do
		start_time = Time.now()
		index = ENV['index']
		if index == nil
			puts "Usage: call with index=the archive to backup"
		else
			backup_archive(index)
		end
		finish_line(start_time)
	end

	desc "Package an individual archive and send it to a server. (param=index,machine -- ex: param=rossetti,nines@nines.org) This gets it ready to be installed on the other server with the sister script: install_archive"
	task :package_archive => :environment do
		start_time = Time.now()
		param = ENV['param']
		if param == nil
			puts "Usage: call with param=the archive to package,the ssh login for the destination machine"
		else
			arr = param.split(',')
			if arr.length != 2
				puts "Usage: call with param=the archive to package,the ssh login for the destination machine"
			else
				index = arr[0]
				dest = arr[1]
				index = "archive_#{index}"
				filename = backup_archive(index)
				cmd_line("scp #{filename} #{dest}:uploaded_data/#{dest_filename_of_zipped_index(index)}")
			end
		end
		finish_line(start_time)
	end

	desc "This assumes a list of gzipped archives in the ~/uploaded_data folder named like this: archive_XXX.tar.gz. (params: archive=XXX,YYY) It will add those archives to the resources index."
	task :install_archive => :environment do
		today = Time.now()
		param = ENV['archive']
		if param == nil
			puts "Usage: call with archive=the archive to install"
		else
			solr = Solr.factory_create(:live)
			folder = "#{ENV['HOME']}/uploaded_data"
			archives = param.split(',')

			indexes = []
			archives.each {|archive|
				index = "archive_#{archive}"
				index_path = "#{folder}/#{index}"
				indexes.push(index_path)
				cmd_line("cd #{folder} && tar xvfz #{index}.tar.gz")
				cmd_line("rm -r -f #{index_path}")
				cmd_line("mv #{folder}/index #{index_path}")
				File.open("#{Rails.root}/log/archive_installations.log", 'a') {|f| f.write("Installed: #{today.getlocal().strftime("%b %d, %Y %I:%M%p")} Created: #{File.mtime(index_path).getlocal().strftime("%b %d, %Y %I:%M%p")} #{archive}\n") }
				solr.remove_archive(archive, false)
			}

			# delete the cache
			TaskUtilities.delete_file("#{Rails.root}/cache/num_docs.txt")

			solr.merge_archives(indexes)
			solr.commit()
			finish_line(start_time)
		end
	end
	
	desc "removes the archive from the resources index (param: archive=XXX,YYY)"
	task :remove_archive  => :environment do
		archives = ENV['archive']
		if archives == nil
			puts "Usage: call with archive=XXX,YYY"
		else
			puts "~~~~~~~~~~~ Remove archive(s) #{archives} from resources..."
			start_time = Time.now
			solr = Solr.factory_create(:live)
			archives = archives.split(',')
			archives.each {|archive|
				solr.remove_archive(archive, false)
			}
			solr.commit()
			solr.optimize()
			finish_line(start_time)
		end
	end

	#desc "This assumes a gzipped archive in the resources folder named like this: YYYY.MM.DD.index.tar.gz"
	#task :install_index => :environment do
	#	today = Time.now()
	#	puts "The following commands will be executed:"
	#	puts "cd #{SOLR_PATH}/solr/data/resources && sudo rm -R index_old"
	#	puts "sudo /sbin/service solr stop"
	#	puts "cd #{SOLR_PATH}/solr/data/resources && sudo mv index index_old"
	#	puts "cd #{SOLR_PATH}/solr/data/resources && tar xvfz #{filename_of_zipped_index()}"
	#	puts "sudo /sbin/service solr start"
	#	puts "rake solr:index_exhibits"
	#	puts "You will be asked for your sudo password."
	#	cmd_line("cd #{SOLR_PATH}/solr/data/resources && sudo rm -R index_old")
	#	cmd_line("sudo /sbin/service solr stop")
	#	cmd_line("cd #{SOLR_PATH}/solr/data/resources && sudo mv index index_old")
	#	cmd_line("cd #{SOLR_PATH}/solr/data/resources && tar xvfz #{filename_of_zipped_index()}")
	#	cmd_line("sudo /sbin/service solr start")
	#	sleep 5
	#	Exhibit.index_all_peer_reviewed()
	#	puts "Finished in #{(Time.now-today)/60} minutes."
	#end
	#
	#desc "Remove exhibits from the main index (in case the index should be zipped up and moved.)"
	#task :remove_exhibits_from_index => :environment do
	#	puts "~~~~~~~~~~~ Removing all peer-reviewed exhibits from solr..."
	#	today = Time.now()
	#	Exhibit.unindex_all_exhibits()
	#	puts "Finished in #{Time.now-today} seconds."
	#end

end
