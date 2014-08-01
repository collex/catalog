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

require "#{Rails.root}/lib/tasks/task_utilities.rb"

namespace :indexer do

	def indexer_path()
		return "#{Rails.root}/lib/tasks/rdf-indexer/target"
	end

	def indexer_name()
		return "rdf-indexer.jar"
	end

	desc "build rdf-indexer file for packaging (this cleans, builds, and copies it)"
	task :build => :environment do
		start_time = Time.now
		indexer_path = INDEXER_PATH
		src = "#{indexer_path}/target"
		dst = indexer_path()
		puts "~~~~~~~~~~~ Copying #{src} to #{dst}..."
		safe_mkpath("#{dst}/lib")
		cmd_line("cd #{indexer_path} && mvn -DskipTests=true clean package")
		cmd_line("rm #{dst}/lib/*.jar")
		cmd_line("rm #{dst}/#{indexer_name()}")
		cmd_line("cp #{src}/lib/*.jar #{dst}/lib/")
		cmd_line("cp #{src}/#{indexer_name()} #{dst}/#{indexer_name()}")
		finish_line(start_time)
	end
end
