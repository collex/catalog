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
				'q' => { :name => 'Query', :param => :term, :default => "*:*", :transformation => get_proc(:transform_query) },
				't' => { :name => 'Title', :param => :term, :default => nil, :transformation => get_proc(:transform_title) },
				'aut' => { :name => 'Author', :param => :term, :default => nil, :transformation => get_proc(:transform_author) },
				'ed' => { :name => 'Editor', :param => :term, :default => nil, :transformation => get_proc(:transform_editor) },
				'pub' => { :name => 'Publisher', :param => :term, :default => nil, :transformation => get_proc(:transform_publisher) },
				'y' => { :name => 'Year', :param => :year, :default => nil, :transformation => get_proc(:transform_year) },
				'a' => { :name => 'Archive', :param => :archive, :default => nil, :transformation => get_proc(:transform_archive) },
				'g' => { :name => 'Genre', :param => :genre, :default => nil, :transformation => get_proc(:transform_genre) },
				'f' => { :name => 'Federation', :param => :federation, :default => nil, :transformation => get_proc(:transform_federation) },
				'o' => { :name => 'Other Facet', :param => :other_facet, :default => nil, :transformation => get_proc(:transform_other) },
				'sort' => { :name => 'Sort', :param => :sort, :default => nil, :transformation => get_proc(:transform_sort) },
				'start' => { :name => 'Starting Row', :param => :starting_row, :default => '0', :transformation => get_proc(:transform_start) },
				'max' => { :name => 'Maximum Results', :param => :max, :default => '30', :transformation => get_proc(:transform_max) },
				'hl' => { :name => 'Highlighting', :param => :highlighting, :default => nil, :transformation => get_proc(:transform_highlight) }
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
				'field' => { :name => 'Field', :param => :field, :default => 'content', :transformation => get_proc(:transform_field) },
				'frag' => { :name => 'Fragment to Match', :param => :term, :default => nil, :transformation => get_proc(:transform_frag) },
				'max' => { :name => 'Maximum matches to return', :param => :max, :default => '15', :transformation => get_proc(:transform_max_matches) },
#TODO:PER do we need this or is this always done?				'clean' => { :name => 'Query', :param => :term },

				'q' => { :name => 'Query', :param => :term, :default => "*:*", :transformation => get_proc(:transform_query) },
				't' => { :name => 'Title', :param => :term, :default => nil, :transformation => get_proc(:transform_title) },
				'aut' => { :name => 'Author', :param => :term, :default => nil, :transformation => get_proc(:transform_author) },
				'ed' => { :name => 'Editor', :param => :term, :default => nil, :transformation => get_proc(:transform_editor) },
				'pub' => { :name => 'Publisher', :param => :term, :default => nil, :transformation => get_proc(:transform_publisher) },
				'y' => { :name => 'Year', :param => :year, :default => nil, :transformation => get_proc(:transform_year) },
				'a' => { :name => 'Archive', :param => :archive, :default => nil, :transformation => get_proc(:transform_archive) },
				'g' => { :name => 'Genre', :param => :genre, :default => nil, :transformation => get_proc(:transform_genre) },
				'f' => { :name => 'Federation', :param => :federation, :default => nil, :transformation => get_proc(:transform_federation) },
				'o' => { :name => 'Other Facet', :param => :other_facet, :default => nil, :transformation => get_proc(:transform_other) }
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
				'q' => { :name => 'Query', :param => :term, :default => "*:*", :transformation => get_proc(:transform_query) },
				't' => { :name => 'Title', :param => :term, :default => nil, :transformation => get_proc(:transform_title) },
				'aut' => { :name => 'Author', :param => :term, :default => nil, :transformation => get_proc(:transform_author) },
				'ed' => { :name => 'Editor', :param => :term, :default => nil, :transformation => get_proc(:transform_editor) },
				'pub' => { :name => 'Publisher', :param => :term, :default => nil, :transformation => get_proc(:transform_publisher) },
				'y' => { :name => 'Year', :param => :year, :default => nil, :transformation => get_proc(:transform_year) },
				'a' => { :name => 'Archive', :param => :archive, :default => nil, :transformation => get_proc(:transform_archive) },
				'g' => { :name => 'Genre', :param => :genre, :default => nil, :transformation => get_proc(:transform_genre) },
				'f' => { :name => 'Federation', :param => :federation, :default => nil, :transformation => get_proc(:transform_federation) },
				'o' => { :name => 'Other Facet', :param => :other_facet, :default => nil, :transformation => get_proc(:transform_other) }
		}
		format.each { |key,val|
			typ = val[:param]
			description = QueryFormat.term_info(typ)
			format[key][:description] = description[:friendly]
			format[key][:exp] = description[:exp]
		}
		return format
	end

	def self.get_proc( method_sym )
	  self.method( method_sym ).to_proc
	end

	def self.transform_query(val)
		return { 'q' => val }
	end

	def self.transform_title(val)
		return { 'title' => val }
	end

	def self.transform_author(val)
		return { 'role_AUT' => val }
	end

	def self.transform_editor(val)
		return { 'role_EDR' => val }
	end

	def self.transform_publisher(val)
		return { 'role_PBL' => val }
	end

	def self.transform_year(val)
		return { 'year_sort' => val }
	end

	def self.transform_archive(val)
		return { 'archive' => val }
	end

	def self.transform_genre(val)
		return { 'genre' => val }
	end

	def self.transform_federation(val)
		return { 'federation' => val }
	end

	def self.transform_other(val)
		return { 'TODO' => val }
	end

	def self.transform_sort(val)
		arr = val.split(' ')

		return { 'sort' => arr[0], 'dir' => arr[1] }
	end

	def self.transform_start(val)
		return { 'start' => val }
	end

	def self.transform_max(val)
		return { 'page_size' => val }
	end

	def self.transform_highlight(val)
		if val == 'on'
			return { 'hl.fl' => 'text', 'hl.fragsize' => 600, 'hl.maxAnalyzedChars' => 512000, 'hl' => true, 'hl.useFastVectorHighlighter' => true }
		else
			return {}
		end
	end

	def self.transform_field(val)
		return { 'field' => val }
	end

	def self.transform_frag(val)
		return { 'fragment' => val }
	end

	def self.transform_max_matches(val)
		#TODO: This should be filtered out before sending to solr
		return { 'max' => val }
	end

	def self.create_solr_query(format, params)
		# A raw parameter is one that is received by this web service.
		# It needs to be transformed into a solr parameter.
		# Format is a hash of a raw parameter that is one of the ones above.
		# Params are the raw parameters, as a hash with the key being the parameter.
		# We will transform them into query.
		# If a parameter doesn't match, an exception is thrown.
		# Defaults are added if it doesn't exist and a default was specified in the format.
		query = {}
		params.each { |key,val|
			definition = format[key]
			raise "Unknown parameter: #{key}" if definition == nil
			raise "Bad parameter: #{val}. Must match: #{definition[:exp].to_s}" if definition[:exp].match(val) == nil
			solr_hash = definition[:transformation].call(val)
			#TODO-PER: what if the same key appears twice? Should they be added together?
			query += solr_hash
		}
		# add defaults
		format.each { |key, definition|
			if query[key] == nil && definition[:default] != nil
				query[key] = definition[:default]
			end
		}

		return query
	end
end
