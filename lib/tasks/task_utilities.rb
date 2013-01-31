module TaskUtilities
	def cmd_line(str)
		puts str
		puts `#{str}`
	end

	def get_folder_tree(starting_dir, directories)
		#define a recursive function that will traverse the directory tree
		# unfortunately, it looks like, at least for OS X and stuff that is returned from SVN, that file? and directory? don't work, so we have some workarounds
		begin
			has_file = false
			Dir.foreach(starting_dir) { |name|
				if !File.file?(name) && name[0] != 46 && name != 'nbproject' && name.index('.rdf') == nil && name.index('.xml') == nil && name.index('.txt') == nil && name[0] != '.'
					path = "#{starting_dir}/#{name}"
					#puts "DIR: #{path}"
					directories = get_folder_tree(path, directories)
				end
				has_file = true if name.index('.rdf') != nil || name.index('.xml') != nil
			}
			directories << starting_dir if has_file
		rescue
			# just ignore if it doesn't work.
		end
		return directories.sort()
	end

	def safe_mkpath(folder)
		# this makes all the folders in the hierarchy
		arr = folder.split('/')
		path = ""
		arr.each { |level|
			path += "/#{level}"
			begin
			Dir.mkdir(path)
			rescue
				# It's ok to fail: it probably means the folder already exists.
			end
		}
	end
	def delete_file(fname)
		begin
			File.delete(fname)
		rescue
		end
	end

	def create_sh_file(name)
		safe_mkpath("#{Rails.root}/log/sh")
		path = "#{Rails.root}/log/sh/#{name}.sh"
		sh = File.open(path, 'w')
		sh.puts("#!/bin/sh\n")
		`chmod +x #{path}`
		return sh
	end

	def finish_line(start_time)
		duration = Time.now-start_time
		if duration >= 60
			str = "Finished in #{"%.2f" % (duration/60)} minutes."
		else
			str = "Finished in #{"%.2f" % duration} seconds."
		end
		puts str
	end
end