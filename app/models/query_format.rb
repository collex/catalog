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

class QueryFormat
	def self.term_info(typ)
		verifications = {
			:term => { :exp => /([+\-]("\w[\w?*]*( \w[\w?*]*)*"|\w[\w?*]*))/, :friendly => "A list of alphanumeric terms, starting with either + or - and possibly quoted if there is a space." },
			:year => { :exp => /([+\-]\d\d\d\d)/, :friendly => "[+-] A four digit date" },
			:archive => { :exp => /([+\-]\w[\w?*]*)/, :friendly => "[+-] One of the predefined archive abbreviations" },
			:genre => { :exp => /([+\-]\w[\w?*]*)+/, :friendly => "[+-] One or more of the predefined genres" },
			:federation => { :exp => /([+\-]\w[\w?*]*)+/, :friendly => "[+-] One or more of the predefined federations" },
			:other_facet => { :exp => /([+\-](freeculture|fulltext|ocr))/, :friendly => "[+-] One of freeculture | fulltext | ocr" },
			:sort => { :exp => /(relevancy|title|name|date) (asc|desc)/, :friendly => "One of relevancy | title | name | date followed by one of asc | desc" },
			:starting_row => { :exp => /\d+/, :friendly => "The zero-based index of the results to start on." },
			:max => { :exp => /\d+/, :friendly => "The page size, or the maximum number of results to return at once." },
			:highlighting => { :exp => /(on|off)/, :friendly => "Whether to return highlighted text, if available. (Pass on or off)" },
			:field => { :exp => /(author|title|editor|publisher|content)/, :friendly => "Which field to autocomplete. (One of author, title, editor, publisher, content)" }
		}

		return verifications[typ]
	end

	def self.catalog_format()
		format = {
				'q' => { :name => 'Query', :param => :term },
				't' => { :name => 'Title', :param => :term },
				'aut' => { :name => 'Author', :param => :term },
				'ed' => { :name => 'Editor', :param => :term },
				'pub' => { :name => 'Publisher', :param => :term },
				'y' => { :name => 'Year', :param => :year },
				'a' => { :name => 'Archive', :param => :archive },
				'g' => { :name => 'Genre', :param => :genre },
				'f' => { :name => 'Federation', :param => :federation },
				'o' => { :name => 'Other Facet', :param => :other_facet },
				'sort' => { :name => 'Sort', :param => :sort },
				'start' => { :name => 'Starting Row', :param => :starting_row },
				'max' => { :name => 'Maximum Results', :param => :max },
				'hl' => { :name => 'Highlighting', :param => :highlighting }
		}
		format.each { |key,val|
			typ = val[:param]
			description = QueryFormat.term_info(typ)
			format[key][:description] = description[:friendly]
			format[key][:exp] = description[:exp]
		}
		return format
	end

	def self.autocomplete_format()
		format = {
				'field' => { :name => 'Field', :param => :field },
				'frag' => { :name => 'Fragment to Match', :param => :term },
				'max' => { :name => 'Maximum matches to return', :param => :max },
#TODO:PER do we need this or is this always done?				'clean' => { :name => 'Query', :param => :term },

				'q' => { :name => 'Query', :param => :term },
				't' => { :name => 'Title', :param => :term },
				'aut' => { :name => 'Author', :param => :term },
				'ed' => { :name => 'Editor', :param => :term },
				'pub' => { :name => 'Publisher', :param => :term },
				'y' => { :name => 'Year', :param => :year },
				'a' => { :name => 'Archive', :param => :archive },
				'g' => { :name => 'Genre', :param => :genre },
				'f' => { :name => 'Federation', :param => :federation },
				'o' => { :name => 'Other Facet', :param => :other_facet }
		}
		format.each { |key,val|
			typ = val[:param]
			description = QueryFormat.term_info(typ)
			format[key][:description] = description[:friendly]
			format[key][:exp] = description[:exp]
		}
		return format
	end

	def self.names_format()
		format = {
				'q' => { :name => 'Query', :param => :term },
				't' => { :name => 'Title', :param => :term },
				'aut' => { :name => 'Author', :param => :term },
				'ed' => { :name => 'Editor', :param => :term },
				'pub' => { :name => 'Publisher', :param => :term },
				'y' => { :name => 'Year', :param => :year },
				'a' => { :name => 'Archive', :param => :archive },
				'g' => { :name => 'Genre', :param => :genre },
				'f' => { :name => 'Federation', :param => :federation },
				'o' => { :name => 'Other Facet', :param => :other_facet }
		}
		format.each { |key,val|
			typ = val[:param]
			description = QueryFormat.term_info(typ)
			format[key][:description] = description[:friendly]
			format[key][:exp] = description[:exp]
		}
		return format
	end
end
