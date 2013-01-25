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

#desc "Do all tasks that routinely need to be done when anything changes in the source repository"
#task :deploy => [ 'deploy:update' ] do
#end
#
#namespace :deploy do
#
#	desc "Do all tasks that routinely need to be done when anything changes in the source repository -- the style of update is in site.yml"
#	task :update => :environment do
#		puts "Getting latest code..."
#		puts `git pull`
#		run_bundler()
#		Rake::Task['db:migrate'].invoke
#		Rake::Task['deploy:update_xsd'].invoke
#
#    `mkdir -p #{Rails.root}/tmp`
#    `touch #{Rails.root}/tmp/restart.txt`
#
#		#puts `sudo /sbin/service httpd restart`
#	end
#
#	desc "Update the xsd files to be publically available"
#	task :update_xsd do
#		puts "Updating xsd files..."
#		safe_mkdir("#{Rails.root}/public/xsd")
#		copy_dir( "#{Rails.root}/features/xsd", "#{Rails.root}/public/xsd" )
#  end
#
#  desc "Migrate old way of creating carousels (carousel_include) to the new way with the archives_carousels table."
#  task :migrate_data_to_archives_carousels_table => :environment do
#    archives = Archive.all
#    archives.each { |archive|
#      if archive.carousel_include == 1
#        if archive.carousels
#          archive.carousels.delete_all
#        end
#        Carousel.all.each { |carousel|
#          archive.carousels << carousel
#        }
#      end
#    }
#  end
#
#	################################
#	# Utilities
#	################################
#
#	def safe_mkdir(folder)
#		begin
#	    Dir.mkdir(folder)
#		rescue
#			# It's ok to fail: it probably means the folder already exists.
#		end
#	end
#
#	def copy_dir( start_dir, dest_dir )
#		puts "Copying the contents of #{start_dir} to #{dest_dir}..."
#		Dir.new(start_dir).each { |file|
#			unless file =~ /\A\./
#				`cp "#{start_dir}/#{file}" "#{dest_dir}/#{file}"`
#			end
#		}
#	end
#
#	def run_bundler()
#    puts `bundle install`
#		#gemfile = "#{Rails.root}/Gemfile"
#		#lock = "#{Rails.root}/Gemfile.lock"
#		#if is_out_of_date(gemfile, lock)
#		#	puts "Updating gems..."
#		#	puts `bundle update`
#		#	`touch #{lock}`	# If there were no changes, the file isn't changed, so it will appear out of date every time this is run.
#		#end
#	end
#
#	def is_out_of_date(src, dst)
#		src_time = File.stat(src).mtime
#		begin
#			dst_time = File.stat(dst).mtime
#		rescue
#			# It's ok if the file doesn't exist; that means that we should definitely recreate it.
#			return true
#		end
#		return src_time > dst_time
#	end
#
#end
