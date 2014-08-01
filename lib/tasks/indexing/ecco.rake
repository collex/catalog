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

namespace :xxx_ecco do
	desc "Test that all ECCO objects have a 856 field (param: max_recs=XXX)"
	task :test_ecco_856 => :environment do
		if CAN_INDEX
			max_records = ENV['max_recs']

			puts "~~~~~~~~~~~ Scanning for 856 fields in estc..."
			start_time = Time.now
			require '#{Rails.root}/script/lib/estc_856_scanner.rb'
			Estc856Scanner.run("#{MARC_PATH}/estc", max_records)
			finish_line(start_time)
		end
	end
end
