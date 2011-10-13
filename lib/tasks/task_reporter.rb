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

class TaskReporter
	@@report_file = nil
	@@report_file_prefix = nil

	def self.set_report_file(fname)
		@@report_file = fname
		begin
			File.delete(fname)
		rescue
		end
		@@report_file_prefix = "Started: #{Time.now}"	# We want the file to be empty unless something important is reported, so delay writing this until the first log message
	end

	def self.report_line_if(str)
		# This only prints the line if the file is empty
		if @@report_file_prefix == nil
			self.report_line(str)
		else
			puts str
		end
	end

	def self.report_line(str)
		if @@report_file
			open(@@report_file, 'a') { |f|
				if @@report_file_prefix
					f.puts @@report_file_prefix
					@@report_file_prefix = nil
				end
				begin
					#f.puts str.encoding.name
					f.puts str
				rescue Exception => e
					f.puts("Continuing after exception: #{e}\n")
					bytes = ''
					str.each_byte { |b|
						bytes += "#{b} "
					}
					f.puts bytes
				end
			}
		end
		begin
			puts str
		rescue Exception => e
			f.puts("Continuing after exception: #{e}\n")
			bytes = ''
			str.each_byte { |b|
				bytes += "#{b} "
			}
			f.puts bytes
		end
	end
end
