require "#{Rails.root}/lib/tasks/task_utilities.rb"
namespace :solr do

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

	def start(sz)
		if sz && sz == 'big'
			sz = "5120"
		else
			sz = "1280"
		end
		port = get_solr_port()
		log_param = "-Djava.util.logging.config.file=etc/logging.properties"
		cmd_line("cd #{SOLR_PATH} && java -Djetty.port=#{port} -DSTOP.PORT=8079 -DSTOP.KEY=c0113x -Xmx#{sz}m #{log_param} -jar start.jar &")
	end

	def stop
		port = get_solr_port()
		cmd_line("cd #{SOLR_PATH} && java -Djetty.port=#{port} -DSTOP.PORT=8079 -DSTOP.KEY=c0113x -jar start.jar --stop")
	end

	desc "Start the solr java app [param: size=big if indexing something large] (for development only! Use service when deploying)"
	task :start, [:size]  => :environment do |t, args|
		port = get_solr_port()
		puts "~~~~~~~~~~~ Starting solr on #{port}..."
		sz = args.size
		start(sz)
	end

	desc "Stop the solr java app"
	task :stop  => :environment do
		puts "~~~~~~~~~~~ Stopping solr..."
		stop()
		puts "Finished."
	end

	desc "Restart the solr java app  [param: size=big if indexing something large]"
	task :restart, [:size]  => :environment do |t, args|
		puts "~~~~~~~~~~~ Restarting solr..."
		stop()
		sz = args.size
		start(sz)
		puts "Finished."
	end

	def dump_hit(label, hit, no_text)
		puts " ------------------------------------------------ #{label} ------------------------------------------------------------------"
		hit.each { |key,val|
			if val.kind_of?(Array)
				val.each{ |v|
					#puts "#{key}: #{trans_str(v)}"
					if key == 'text'
						v = v.force_encoding("UTF-8")
					end
					puts "#{key}: #{v}" if no_text == false || key != 'text'
				}
			else
				#puts "#{key}: #{trans_str(val)}"
				if key == 'text'
					val = val.force_encoding("UTF-8")
				end
				puts "#{key}: #{val}" if no_text == false || key != 'text'
			end
		}
	end

	desc "examine solr document, both in the regular index and the reindexing index (param: uri=XXX text=yes|no)"
	task :examine  => :environment do
		uri = ENV['uri']
		text = ENV['text']
		no_text = text == 'no'
		solr = Solr.factory_create(:live)
		begin
			hit = solr.details({ :q => "uri:#{uri}" }, { :field_list => [] })
		rescue SolrException => e
			puts "Error: #{e}"
		end
		dump_hit("RESOURCES", hit, no_text) if hit

		solr = Solr.factory_create(:shards)
		begin
			hit = solr.details({ :q => "uri:#{uri}" }, { :field_list => [] })
		rescue SolrException => e
			puts "Error: #{e}"
		end
		dump_hit("REINDEX", hit, no_text) if hit
	end

	desc "dump a bunch of objects at once from the resources index (param: uri=uri,uri...)"
	task :dump => :environment do
		uri = ENV['uri']
		no_text = true
		solr = Solr.factory_create(:live)
		uris = uri.split(',')
		uris.each { |uri|
			begin
				hit = solr.details({ :q => "uri:#{uri}" }, { :field_list => [] })
				dump_hit("RESOURCES", hit, no_text) if hit
			rescue SolrException => e
				puts "Error: #{e}"
			end
		}
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

  def uploaded_data_index
    File.join(Rails.application.secrets.folders['uploaded_data'], "index")
  end

	def filename_of_zipped_index(archive)
		today = Time.now()
      return File.join(Rails.application.secrets.folders['backups'], "#{archive}.#{today.strftime('20%y.%m.%d')}.tar.gz")
	end

	def dest_filename_of_zipped_index(archive)
		return File.join(Rails.application.secrets.folders['uploaded_data'], "#{archive}.tar.gz")
	end

	def backup_archive(archive)
		filename = filename_of_zipped_index(archive)
		puts "zipping index \"#{archive}\"..."
		solr_folder = "archives"
		solr_folder = "pages" if archive.index("pages_") == 0
		cmd_line("cd #{SOLR_PATH}/solr/#{solr_folder}/#{archive} && tar cvzf #{filename} index")
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

	desc "This will delete the current index and replace it with the new index that was placed in #{Rails.application.secrets.folders['uploaded_data']}"
	task :replace_resources => :environment do
		start_time = Time.now()
		puts "This will zip up the current archive and replace it with the new archive."
		puts "Solr will be down for part of this time, but as much as possible will be done with solr still online."
		puts "~~~~~ Unzip new archive and put it in the correct place."
		cmd_line("rm -R #{uploaded_data_index}")
		cmd_line("cd #{Rails.application.secrets.folders['uploaded_data']} && tar xvfz #{dest_filename_of_zipped_index('resources')}")
		cmd_line("mv #{uploaded_data_index} #{SOLR_PATH}/solr/archives/resources/index_new")
		cmd_line("sudo /sbin/service solr stop")
		cmd_line("mv #{SOLR_PATH}/solr/archives/resources/index #{uploaded_data_index}")
		cmd_line("mv #{SOLR_PATH}/solr/archives/resources/index_new #{SOLR_PATH}/solr/archives/resources/index")
		cmd_line("sudo /sbin/service solr start")
		cmd_line("cd #{Rails.application.secrets.folders['uploaded_data']} && tar cvfz resources_old.tar.gz index")
		finish_line(start_time)
	end
end
