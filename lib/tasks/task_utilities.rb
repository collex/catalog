class TaskUtilities
	def self.get_folder_tree(starting_dir, directories)
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

	def self.delete_file(fname)
		begin
			File.delete(fname)
		rescue
		end
	end

	def self.create_sh_file(name)
		path = "#{Rails.root}/tmp/#{name}.sh"
		sh = File.open(path, 'w')
		sh.puts("#!/bin/sh\n")
		`chmod +x #{path}`
		return sh
	end


end