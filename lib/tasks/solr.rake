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
		solr = Solr.factory_create(false)
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
			index.optimize()
			puts "Finished in #{(Time.now-start_time)/60} minutes."
		end
	end
end
