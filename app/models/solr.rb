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

require 'rsolr'
# documentation at: http://github.com/mwmitchell/rsolr

class Solr
	def initialize(core)
		if core.kind_of?(Array)
			base_url = SOLR_URL.gsub("http://", "")
			@shards = core.collect { |shard| base_url + '/' + shard }

			core = core[0]
		else
			@shards = nil
		end
		@core = core # "#{SOLR_CORE_PREFIX}/#{core}"
		@solr = RSolr.connect( :url=>"#{SOLR_URL}/#{core}" )
		@field_list = [ "uri", "archive", "date_label", 'year', "genre", "source", "image", "thumbnail", "title", "alternative", "url",
			"role_ART", "role_AUT", "role_EDT", "role_PBL", "role_TRL", "role_EGR", "role_ETR", "role_CRE", "role_OWN", "freeculture",
			"is_ocr", "federation", "has_full_text", "source_xml", "provenance", "discipline", 'typewright',
      "role_ARC", "role_BND", "role_BKD", "role_BKP", "role_CLL", "role_CTG", "role_COL", "role_CLR", "role_CWT", "role_COM", "role_CMT",
      "role_DUB", "role_FAC", "role_ILU", "role_ILL", "role_LTG", "role_PRT", "role_POP", "role_PRM",
      "role_RPS", "role_RBR", "role_SCR", "role_SCL", "role_TYD", "role_TYG", "role_WDE", "role_WDC",
      "subject"
    ]
		@facet_fields = ['genre','archive','freeculture', 'has_full_text', 'federation', 'typewright', 'doc_type', 'discipline']
    @role_facets = [ 'role_AUT', 'role_ART', 'role_EDT', 'role_PBL', 'role_OWN', 'role_TRL', 'role_ARC', 'role_BND', 'role_BKD',
                     'role_BKP', 'role_CLL', 'role_CTG', 'role_COL', 'role_CLR', 'role_CWT', 'role_COM', 'role_CMT', 'role_CRE',
                     'role_DUB', 'role_FAC', 'role_ILU', 'role_ILL', 'role_LTG', 'role_PRT', 'role_POP', 'role_PRM', 'role_RPS',
                     'role_RBR', 'role_SCR', 'role_SCL', 'role_TYD', 'role_TYG', 'role_WDE', 'role_WDC' ]
    @facet_fields += @role_facets  # if this causes problems make it MESA only.
	end

	def self.factory_create(is_test, federation="")
		name = ""
		if federation == ""
			if is_test == :test
				name = "testResources"
			elsif is_test == :live
				name = "resources"
			elsif is_test == :shards
				name = self.get_archive_core_list()
			else
				raise "Bad parameter in Solr.factory_create"
			end
		else	# if a federation is passed, then we are using the local index
			name = is_test == :test ? "test" : ""
			name += federation + "LocalContent"
		end
		return Solr.new(name)
	end

	private
	def select(options, noisy = true)
		options['version'] = '2.2'
		options['defType'] = 'edismax'
		if @shards
			options[:shards] = @shards.join(',')
		end
		if options[:q].blank? && options['q'].blank?
			options['q'] = "*:*"
		end
		begin
			ret = @solr.post( 'select', :data => options )
		rescue Errno::ECONNREFUSED => e
			raise SolrException.new("Cannot connect to the search engine at this time.")
		rescue RSolr::Error::Http => e
			raise SolrException.new(e.to_s)
		end
		uri = ret.request[:uri].to_s
		arr = uri.split('/')
		index = arr[arr.length-2]

		ActiveRecord::Base.logger.info("*** SOLR: [#{index}] #{ret.request[:data]}") if noisy

		return ret
	end

	def add_facet_param(options, fields, prefix = nil)
		# the three ways to call this are, regular search, where the prefix is nil,
		# name search, where the prefix is "", and autocomplete, where the prefix is passed in.
		options[:facet] = true
		options["facet.field"] = fields
		options["facet.mincount"] = 1
		options["facet.limit"] = -1
		if prefix
			if prefix != ""
				options["facet.method"] = 'enum'
				options["facet.prefix"] = prefix
			end
			options["facet.missing"] = false
		else
			options["facet.missing"] = true
		end
		return options
	end

	def add_field_list_param(options, fields)
		options[:fl] = fields.join(' ')
		return options
	end

	public
	def self.get_totals(is_test)
		return Solr.factory_create(is_test).get_totals()
	end

	def get_facet_list(typ)
		options = { :q=>"*:*", :rows => 1 }
		options = add_facet_param(options, [ typ ])
		response = select(options)
		results = []
		if response && response['facet_counts'] && response['facet_counts']['facet_fields'] && response['facet_counts']['facet_fields'][typ]
			facets = response['facet_counts']['facet_fields'][typ]
			skip_next = false
			facets.each {|f|
				if f.kind_of?(String)
					results.push(f)
				end
			}
		end
		return results
	end

	def get_federation_list()
		return get_facet_list('federation')
	end

	def get_archive_list()
		return get_facet_list('archive')
  end

  def get_language_list()
    return get_facet_list('language')
  end

	def get_totals()
		federations = get_federation_list()
		totals = []
		federations.each { |federation|
			options = { :q=>"federation:#{federation}", :rows => 1 }
			options = add_facet_param(options, [ 'archive' ])
			response = select(options)
			archive_num = 0
			if response && response['facet_counts'] && response['facet_counts']['facet_fields'] && response['facet_counts']['facet_fields']['archive']
				facets = response['facet_counts']['facet_fields']['archive']
				skip_next = false
				facets.each {|f|
					if f.kind_of?(Fixnum) && f.to_i > 0 && skip_next == false
						archive_num = archive_num + 1
					elsif f.kind_of?(String) && f.include?('exhibit_')
						skip_next = true
					else
						skip_next = false
					end
				}
			end
			totals.push( { :federation => federation, :total => response['response']['numFound'], :sites => archive_num } )
		}
		return totals
	end

	def massage_hits(response)
		# correct the character set for all fields
		if response && response['response'] && response['response']['docs']
			response['response']['docs'].each { |doc|
				doc.each { |k,v|
					if v.kind_of?(String)
						doc[k] = v.force_encoding("UTF-8")
					elsif v.kind_of?(Array)
						v.each_with_index { |str, i|
							if str.kind_of?(String)
								v[i] = str.force_encoding("UTF-8")
							end
						}
					end
				}
			}
		end

		# Correct the fields that are erroneously returned as multi from solr.
		# TODO-PER: This should be corrected in the schema, then the following can disappear.
		if response && response['response'] && response['response']['docs']
			response['response']['docs'].each { |doc|
				doc['title'] = doc['title'].join("") if doc['title'] && doc['title'].kind_of?(Array)
				doc['url'] = doc['url'].join("") if doc['url'] && doc['url'].kind_of?(Array)
			}
		end
	end

	def process_fq(options)
		# do separate 'fq' fields for each and add the tag var
		if !options['fq'].blank?
			# we can't split spaces that are quoted. We just want to split spaces that appear before + or -
			options['fq'] = options['fq'].gsub(' +', '@+').gsub(' -', '@-')
			fq = options['fq'].split('@')
			# we only want one field for all the federations, though. We need to put those back.
			fed_idx = -1
			fq.each_with_index { |op, i|
				if op.include?("federation:")
					if fed_idx == -1
						fq[i] = '{!tag=fed}' + op
						fed_idx = i
					else
						fq[fed_idx] += " OR #{op}"
						fq[i] = nil
					end
				elsif op.include?("archive:")
					fq[i] = '{!tag=arch}' + op
				end
			}
			fq.compact!
			options['fq'] = fq
		end

	end

	def search(options, overrides = {})
		options = add_facet_param(options, @facet_fields) if overrides[:no_facets] == nil
		fields = overrides[:field_list] ? overrides[:field_list] : @field_list
		options = add_field_list_param(options, fields)
		key_field = overrides[:key_field] ? overrides[:key_field] : 'uri'

		process_fq(options)

		# add the variable to the facet field
		if !options['facet.field'].blank?
			options['facet.field'].each_with_index { |op, i|
				if op == 'archive'
					options['facet.field'][i] = '{!ex=arch}archive'
				elsif op == 'federation'
					options['facet.field'][i] = '{!ex=fed}federation'
				end
			}
		end

		ret = select(options)

		massage_hits(ret)

		# highlighting is returned as a hash of uri to a hash that is either empty or contains 'text' => Array of one string element.
		# simplify this to return either nil or a string.
		if ret && ret['highlighting']
			ret['response']['docs'].each { |hit|
				highlight = ret['highlighting'][hit[key_field]]
				if highlight && highlight['text']
					str = highlight['text'].join("\n") # This should always return an array of size 1, but just in case, we won't throw away any items.
					hit['text'] = str.force_encoding("UTF-8")
				end
			}
		end

		facets = facets_to_hash(ret)
		#facets['federation'] = adjust_federation_counts(options, facets['federation'])
		#facets['archive'] = adjust_archive_counts(options, facets['archive'])

		return { :total => ret['response']['numFound'], :hits => ret['response']['docs'], :facets => facets }
	end

	def adjust_facet_counts(facet, src_options, prior_facets)
		# if the search included that facet, then do the search again without it to get the facet totals.
		# if the search didn't include that facet, then we already have the totals, so there's nothing to do.
		return prior_facets if !src_options['fq'].blank? && !src_options['fq'].include?(facet + ':')

		# trim out any archive constraints. To get counts, we want them all
		options = {}
		src_options.each { |key,val|
			options[key] = val if key != 'f' && key != 'hl'
		}
		options[:fl] = 'uri'
		options['facet.field'] = [ facet ]
		options['rows'] = 1
		options['fq'] = options['fq'].gsub(/[\+-]#{facet}:\"?[\w ]+\"?( AND )?/, '') if !options['fq'].blank?
		options.delete('fq') if options['fq'].blank?

		ret = select(options)

		# Reformat the facets into what the UI wants, so as to leave that code as-is for now
		# tack the new archive info into the original results map
		facets = facets_to_hash(ret)
		return facets[facet]
	end

	def adjust_archive_counts(src_options, prior_facets)
		return adjust_facet_counts('archive', src_options, prior_facets)
	end

	def adjust_federation_counts(src_options, prior_facets)
		return adjust_facet_counts('federation', src_options, prior_facets)
	end

	def auto_complete(options)	# called for autocomplete
		facet = options['field']
		prefix = options['fragment']
		options.delete('field')
		options.delete('fragment')

		options[:start] = 0
		options[:rows] = 0
		options = add_facet_param(options, [facet], prefix)
		process_fq(options)

		response = select(options)
		return facets_to_hash(response)[facet]
	end

	def names(options)	# called for the names entry point
		options[:start] = 0
		options[:rows] = 0
		options[:fl] = "role_AUT role_EDT role_PBL"
		add_facet_param(options, [ "role_AUT", "role_EDT", "role_PBL" ], "")
		response = select(options)
		return facets_to_hash(response)
  end

  def languages(options)
    if options.empty?
      options = { :q=>"*:*", :rows => 1 }
    end
    options[:fl] = "language"
    add_facet_param(options, [ "language" ], "")
    response = select(options)
    return facets_to_hash(response)
  end

	def details(options, overrides = {})
		fields = overrides[:field_list] ? overrides[:field_list] : @field_list
		options = add_field_list_param(options, fields)
		if overrides[:quiet]
			response = select(options, false)
		else
			response = select(options)
		end
		if response && response['response'] && response['response']['docs'] && response['response']['docs'].length > 0
			massage_hits(response)

			return response['response']['docs'][0]
		else
			q = options[:q]
			q = options['q'] if q.blank?
			q = '' if q.blank?
			raise SolrException.new("Cannot find the object \"#{q.sub('uri:','')}\"", :not_found)
		end
	end

	def full_object(uri)
		begin
			return self.details({ q: "uri:#{uri}" }, { field_list: [ '*' ], quiet: true })
		rescue RSolr::Error::Http => e
			str = e.to_s
			arr = str.split("\nBacktrace:")
			raise SolrException.new("UNEXPECTED ERROR: #{arr[0]}")
		end
	end

	def facets_to_hash(ret)
		# make the facets more convenient. They are returned as a hash, with each key being the facet type.
		# Then the value is an array. The values of the array alternate between the name of the facet and the
		# count of the number of objects that match it. There is also a nil value that needs to be ignored.
		facets = {}
		if ret && ret['facet_counts'] && ret['facet_counts']['facet_fields']
			ret['facet_counts']['facet_fields'].each { |key,raw_list|
				facet = []
				name = ''
				raw_list.each { |item|
					if name == ''
						name = item
					else
						if name != nil
							facet.push({ :name => name, :count => item })
						end
						name = ''
					end
				}
				facets[key] = facet
			}
		end
		return facets
	end

	def add_object(fields, relevancy, commit_now, is_retry = false) # called by Exhibit to index exhibits
		# this takes a hash that contains a set of fields expressed as symbols, i.e. { :uri => 'something' }
		begin
			if relevancy
				@solr.add(fields) do |doc|
					doc.attrs[:boost] = relevancy # boost the document
				end
				add_xml = @solr.xml.add(fields, {}) do |doc|
					doc.attrs[:boost] = relevancy
				end
				@solr.update(:data => add_xml)
			else
				@solr.add(fields)
			end
		rescue Exception => e
			puts("ADD OBJECT: Continuing after exception: #{e}")
			puts("URI: #{fields['uri']}")
			puts("#{fields.to_s}")
			if is_retry == false
				add_object(fields, relevancy, commit_now, true)
			else
				raise SolrException.new(e.to_s)
			end
		end
		begin
			if commit_now
				@solr.commit()
			end
		rescue Exception => e
			raise SolrException.new(e.to_s)
		end
	end

	def remove_archive(archive, commit_now)
		begin
			@solr.delete_by_query("+archive:\"#{archive}\"")
			if commit_now
				@solr.commit()
			end
		rescue Exception => e
			raise SolrException.new(e.to_s)
		end
	end

	def remove_exhibit(exhibit, commit_now)
		begin
			@solr.delete_by_query("+uri:#{exhibit}\\/*")
			if commit_now
				@solr.commit()
			end
		rescue Exception => e
			raise SolrException.new(e.to_s)
		end
	end

	def merge_archives(archives, internal=true)
		#http://localhost:8983/solr/admin/cores?action=mergeindexes&core=core0&srcCore=core1&srcCore=core2
		solr = RSolr.connect( :url=> SOLR_URL, :read_timeout => 200, :open_timeout => 200 )
		begin
			if internal
				solr.post("admin/cores", { :params => {:action => "mergeindexes", :core => @core, :srcCore => archives } })
			else
				solr.post("admin/cores", { :params => {:action => "mergeindexes", :core => @core, :indexDir => archives } })
			end
			commit()
		rescue RSolr::Error::Http => e
			commit()
			str = e.to_s
			arr = str.split("\nBacktrace:")
			raise SolrException.new(arr[0])
    end
	end

	def remove_object(uri, commit_now)
		begin
			@solr.delete_by_query("+key:#{uri}")
			if commit_now
				@solr.commit()
			end
		rescue Exception => e
			raise SolrException.new(e.to_s)
		end
	end

	def clear_core()
		if @core.include?("LocalContent")
			@solr.delete_by_query "*:*"
		else
			raise SolrException.new("Cannot clear the core #{@core}")
		end
	end

	def commit()
		@solr.commit() # :wait_searcher => false, :wait_flush => false, :shards => @cores)
	end

	def optimize()
		@solr.optimize() #(:wait_searcher => true, :wait_flush => true)
	end

	def self.get_archive_core_list()
		#return [ "resources", "testResources" ]
		url = "#{SOLR_URL}/admin/cores?action=STATUS"
		resp = `curl #{url}`	# this returns some info on all the cores. We can ignore most of it, we are just looking for the names that start with "archive_"
		arr = resp.split('<lst name="archive_')
		arr.delete_at(0)	# this gets rid of the header.
		archives = []
		arr.each{ |a|
			arr2 = a.split('"')
			archives.push("archive_#{arr2[0]}")
		}
		return archives.sort()
	end

##########################################################################
##########################################################################
####### INDEXING HELPERS
##########################################################################
##########################################################################

	def self.archive_to_core_name(archive)
		return archive.gsub(/[:\s,]/, "_")
	end
	
end

##########################################################################
##########################################################################
##########################################################################
##########################################################################
##########################################################################
#class CollexEngine
#
#	def solr_select(options)
#		if options[:field_list]
#			options[:fl] = options[:field_list].join(' ')
#			options[:field_list] = nil
#		end
#		if options[:facets]
#			options[:facet] = true
#			options["facet.field"] = options[:facets][:fields]
#			options["facet.prefix"] = options[:facets][:prefix]
#			options["facet.missing"] = options[:facets][:missing]
#			options["facet.method"] = options[:facets][:method]
#			options["facet.mincount"] = 1
#			options["facet.limit"] = -1
#			options[:facets] = nil
#		end
#		if options[:highlighting]
#			options['hl.fl'] = options[:highlighting][:field_list]
#			options['hl.fragsize'] = options[:highlighting][:fragment_size]
#			options['hl.maxAnalyzedChars'] = options[:highlighting][:max_analyzed_chars]
#			options['hl'] = true
#			options['hl.useFastVectorHighlighter'] = true
#			options[:highlighting] = nil
#		end
#		# We don't need to use shards if there is only one index
#		if options[:shards]
#			if options[:shards].length == 1
#				options[:shards] = nil
#			else
#				options[:shards] = options[:shards].join(',')
#			end
#		end
##		return @solr.select(:params => options)
#		ret = @solr.post( 'select', :data => options )
#
#		# correct the character set for all fields
#		if ret && ret['response'] && ret['response']['docs']
#			ret['response']['docs'].each { |doc|
#				doc.each { |k,v|
#					if v.kind_of?(String)
#						doc[k] = v.force_encoding("UTF-8")
#					elsif v.kind_of?(Array)
#						v.each_with_index { |str, i|
#							if str.kind_of?(String)
#								v[i] = str.force_encoding("UTF-8")
#							end
#						}
#					end
#				}
#			}
#		end
#		# highlighting is returned as a hash of uri to a hash that is either empty or contains 'text' => Array of one string element.
#		# simplify this to return either nil or a string.
#		if ret && ret['highlighting']
#			ret['highlighting'].each { |uri,hsh|
#				if hsh.length == 0 || hsh['text'] == nil || hsh['text'].length == 0
#					ret['highlighting'][uri] = nil
#				else
#					str = hsh['text'].join("\n") # This should always return an array of size 1, but just in case, we won't throw away any items.
#					ret['highlighting'][uri] = str.force_encoding("UTF-8")
#				end
#			}
#		end
#		return ret
#	end
#
#	def query_num_docs()
#		response = solr_select(:q=>"federation:#{DEFAULT_FEDERATION}", :rows => 1, :facets => {:fields => 'archive', :mincount => 1, :missing => true, :limit => -1}, :shards => @cores)
#		archive_num = 0
#		if response && response['facet_counts'] && response['facet_counts']['facet_fields'] && response['facet_counts']['facet_fields']['archive']
#			facets = response['facet_counts']['facet_fields']['archive']
#			skip_next = false
#			facets.each {|f|
#				if f.kind_of?(Fixnum) && f.to_i > 0 && skip_next == false
#					archive_num = archive_num + 1
#				elsif f.kind_of?(String) && f.include?('exhibit_')
#					skip_next = true
#				else
#					skip_next = false
#				end
#			}
#		end
#		return { :total => response['response']['numFound'], :sites => archive_num }
#	end
#
#	def warm_num_doc_cache()
#		if @num_docs == -1 || @num_sites == -1
#			begin
#				File.open("#{Rails.root}/cache/num_docs.txt", "r") { |f|
#					str = f.read
#					arr = str.split(',')
#					if arr == 2
#						@num_docs = arr[0].to_i
#						@num_sites = arr[1].to_i
#					end
#				}
#			rescue
#			end
#			if @num_docs <= 0
#				ret = query_num_docs()
#				@num_docs = ret[:total]
#				@num_sites = ret[:sites]
#				File.open("#{Rails.root}/cache/num_docs.txt", 'w') {|f| f.write("#{@num_docs},#{@num_sites}") }
#			end
#		end
#	end
#
#	def tank_citations(query)
#		#return "(*:* AND #{query}) OR (*:* AND #{query} -genre:Citation)^5"
#		if query.length > 0
#			return "(#{query}) OR (#{query} -genre:Citation)^5"
#		else
#			return "(*:*) OR (*:* -genre:Citation)^5"
#		end
#	end
#
#	def name_facet(constraints)	# called when the "Click here to see the top authors..." is clicked
#		query, filter_queries = solrize_constraints(constraints)
#		response = solr_select(:start => 0, :rows => 0,
#					:q => query, :fq => filter_queries,
#					:field_list => [ 'role_AUT', 'role_EDT', 'role_PBL'],
#					:facets => {:fields => [ 'role_AUT', 'role_EDT', 'role_PBL'], :mincount => 1, :missing => false, :limit => -1},
#					:shards => @cores)
#
#		facets = response['facet_counts']['facet_fields']
#		facets = facets_to_hash(facets)
#		facets2 = {}
#		facets.each { |ty, facet|
#			facets2[ty] = facet.sort { |a,b| (a[1] == b[1]) ? a[0] <=> b[0] : b[1] <=> a[1] }
#		}
#
#		return facets2
#	end
#
#	def search_user_content(options)
#		# input parameters:
#		facet_exhibit = options[:facet][:exhibit]	# bool
#		facet_cluster = options[:facet][:cluster]	# bool
#		facet_group = options[:facet][:group]	# bool
#		facet_comment = options[:facet][:comment]	# bool
#		facet_federation = options[:facet][:federation]	#bool
#		facet_section = options[:facet][:section]	# symbol -- enum: classroom|community|peer-reviewed
#		member = options[:member]	# array of group
#		admin = options[:admin]	# array of group
#		search_terms = options[:terms]	# array of strings, they are ANDed
#		sort_by = options[:sort_by]	# symbol -- enum: relevancy|title_sort|last_modified
#		page = options[:page]	# int
#		page_size = options[:page_size]	#int
#		facet_group_id = options[:facet][:group_id]	# int
#
#		query = "federation:#{facet_federation} AND section:#{facet_section}"
#		if search_terms != nil
#			# get rid of special symbols
#			search_terms = search_terms.gsub(/\W/, ' ')
#			arr = search_terms.split(' ')
#			arr.each {|term|
#				query += " AND content:#{term}"
#			}
#		end
#
#		group_members = ""
#		member.each {|ar|
#			group_members += " OR visible_to_group_member:#{ar.id}"
#		}
#
#		group_admins = ""
#		admin.each {|ar|
#			group_admins += " OR visible_to_group_admin:#{ar.id}"
#		}
#		query += " AND (visible_to_everyone:true #{group_members} #{group_admins})"
#		if facet_group_id
#			query += " AND group_id:#{facet_group_id}"
#		end
#
#		arr = []
#		arr.push("object_type:Exhibit") if facet_exhibit
#		arr.push("object_type:Cluster") if facet_cluster
#		arr.push("object_type:Group") if facet_group
#		arr.push("object_type:DiscussionThread") if facet_comment
#		all_query = query
#		if arr.length > 0
#			query += " AND ( #{arr.join(' OR ')})"
#		end
#
#		puts "QUERY: #{query}"
#		ActiveRecord::Base.logger.info("*** USER QUERY: #{query}")
#		case sort_by
#		when :relevancy then sort = nil
#		when :title_sort then sort = "#{sort_by.to_s} asc"
#		when :last_modified then sort = "#{sort_by.to_s} desc"
#		end
#
#		response = solr_select(:start => page*page_size, :rows => page_size, :sort => sort,
#						:q => query,
#						:field_list => [ 'key', 'object_type', 'object_id', 'last_modified' ],
#						:highlighting => {:field_list => ['text'], :fragment_size => 200, :max_analyzed_chars => 100 })
#
#		response_total = solr_select(:start => 1, :rows => 1, :q => all_query,
#						:field_list => [ 'key', 'object_type', 'object_id', 'last_modified' ])
#
#		results = { :total => response_total['response']['numFound'], :total_hits => response['response']['numFound'], :hits => response['response']['docs'] }
#		# add the highlighting to the object
#		if response['highlighting'] && search_terms != nil
#			highlight = response['highlighting']
#			results[:hits].each  {|hit|
#				this_highlight = highlight[hit['key']]
#				hit['text'] = this_highlight if this_highlight && this_highlight['text']
#			}
#		end
#		# the time is a string formatted as: 1995-12-31T23:59:59Z or 1995-12-31T23:59:59.999Z
#		results[:hits].each  {|hit|
#			dt = hit['last_modified'].split('T')
#			hit['last_modified'] = nil	# in case it wasn't a valid time below.
#			if dt.length == 2
#				dat = dt[0].split('-')
#				tim = dt[1].split(':')
#				if dat.length == 3 && tim.length > 2
#					t = Time.gm(dat[0], dat[1], dat[2], tim[0], tim[1])
#					hit['last_modified'] = t
#				end
#			end
#		}
#return results
#	end
#
#  # Search SOLR for documents matching the constraints.
#  #
#  def search(constraints, start, max, sort_by, sort_ascending)
#
#    # turn map of constraint data into solr quert strings
#    query, filter_queries = solrize_constraints(constraints)
#
#	  # this is the full search. We want sorting, highlighting and non-citation links preferred
#	  if sort_ascending
#      sort_param = sort_by ? "#{sort_by} asc" : nil
#    else
#      sort_param = sort_by ? "#{sort_by} desc" : nil
#    end
#    query = tank_citations(query)
#		response = solr_select(:start => start, :rows => max, :sort => sort_param,
#					:q => query, :fq => filter_queries,
#					:field_list => @field_list,
#					:facets => {:fields => @facet_fields, :mincount => 1, :missing => true, :limit => -1},
#					:highlighting => {:field_list => ['text'], :fragment_size => 600, :max_analyzed_chars => 512000 }, :shards => @cores)
#
#    results = {}
#    results["total_hits"] = response['response']['numFound']
#    results["hits"] = response['response']['docs']
#
#    # Reformat the facets into what the UI wants, so as to leave that code as-is for now
#    results["facets"] = facets_to_hash(response['facet_counts']['facet_fields'])
#    results["highlighting"] = response['highlighting']
#
#    # append the total for the other federation
#  	return append_federation_counts(constraints, results)
#
#  end
#
#  private
#
#  public
#	def get_object(uri, all_fields = false) #called when "collect" is pressed.
#		# Returns nil if the object doesn't exist, or the object if it does.
#		query = "uri:#{CollexEngine.query_parser_escape(uri)}"
#		if all_fields == true
#			field_list = @all_fields_except_text
#		else
#			field_list = @field_list
#		end
#
#		response = solr_select(:start => 0, :rows => 1,
#             :q => query, :field_list => field_list, :shards => @cores)
#		if response['response']['docs'].length > 0
##			fix_free_culture(response['response']['docs'][0])
#	    return response['response']['docs'][0]
#		end
#		return nil
#	end
#
#	def get_object_with_text(uri)
#		# Returns nil if the object doesn't exist, or the object if it does.
#		query = "uri:#{CollexEngine.query_parser_escape(uri)}"
#
#		response = solr_select(:start => 0, :rows => 1,
#			:q => query, :shards => @cores)
#		return response['response']['docs'][0] if response['response']['docs'].length > 0
#		return nil
#	end
#
#	def add_object(fields, relevancy = nil, is_retry = false) # called by Exhibit to index exhibits
#		# this takes a hash that contains a set of fields expressed as symbols, i.e. { :uri => 'something' }
##		doc = Solr::Document.new(fields)
##		doc.boost = relevancy if relevancy != nil
##		@solr.add(doc)
#		begin
#			if relevancy
#				@solr.add(fields) do |doc|
#					doc.attrs[:boost] = relevancy # boost the document
#				end
#				add_xml = @solr.xml.add(fields, {}) do |doc|
#					doc.attrs[:boost] = relevancy
#				end
#				@solr.update(:data => add_xml)
#			else
#				@solr.add(fields)
#			end
#		rescue Exception => e
#			CollexEngine.report_line("ADD OBJECT: Continuing after exception: #{e}\n")
#			CollexEngine.report_line("URI: #{fields['uri']}\n")
#			CollexEngine.report_line("#{fields.to_s}\n")
#			add_object(fields, relevancy, true) if is_retry == false
#		end
#	end
#
#	#
#	# Simple utils from solr-ruby
#	#
#
#	# paired_array_each([key1,value1,key2,value2]) yields twice:
#	#     |key1,value1|  and |key2,value2|
#	def self.paired_array_each(a, &block)
#		0.upto(a.size / 2 - 1) do |i|
#			n = i * 2
#			yield(a[n], a[n+1])
#		end
#	end
#
#	def self.query_parser_escape(string)
#		# backslash prefix everything that isn't a word character
#		string.gsub(/(\W)/,'\\\\\1')
#	end
#
#
#private
#	def self.print_error(uri, total_errors, first_error, msg)
#		CollexEngine.report_line("---#{uri}---\n") if first_error
#		total_errors += 1
#		first_error = false
#		CollexEngine.report_line("    #{msg}\n")
#		return total_errors, first_error
#	end
