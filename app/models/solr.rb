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

      @core = core
      @solr = RSolr.connect( :url=>"#{SOLR_URL}/#{core}" )

      if core == "pages"
         @field_list = [ "uri", "archive", "page_num", "page_of" ]
         @facet_fields = []
      else
         @field_list = [ "uri", "archive", "date_label", 'year', "genre", "source", "image", "thumbnail", "title", "alternative", "url",
   			"role_ART", "role_AUT", "role_EDT", "role_PBL", "role_TRL", "role_EGR", "role_ETR", "role_CRE", "role_OWN", "freeculture",
   			"is_ocr", "federation", "has_full_text", "source_xml", "provenance", "discipline", 'typewright',
            "role_ARC", "role_BND", "role_BKD", "role_BKP", "role_CLL", "role_CTG", "role_COL", "role_CLR", "role_CWT", "role_COM", "role_CMT",
            "role_DUB", "role_FAC", "role_ILU", "role_ILL", "role_LTG", "role_PRT", "role_POP", "role_PRM",
            "role_RPS", "role_RBR", "role_SCR", "role_SCL", "role_TYD", "role_TYG", "role_WDE", "role_WDC",
   	      "role_BRD", "role_CNG", "role_CND", "role_DRT", "role_IVR", "role_IVE", "role_OWN", "role_FMO", "role_PRF", "role_PRO", "role_PRN",
            "has_pages", "hasPart", "isPartOf", "decade", "quarter_century", "half_century", "century", "subject"
         ]
         @facet_fields = ['genre','archive','freeculture', 'has_full_text', 'federation', 'typewright', 'doc_type', 'discipline', 'role']
      end
   end

   def self.factory_create(is_test, federation="")
      name = ""
      if federation == ""
         if is_test == :test
            name = "testResources"
         elsif is_test == :live
            name = "resources"
         elsif is_test == :pages
            name = "pages"
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
		rescue Timeout::Error => e
			# Is there a way to reset the solr service at this point to recover?
			raise SolrException.new(e.to_s)
		end

		if noisy
			uri = ret.request[:uri].to_s
			arr = uri.split('/')
			index = arr[arr.length-2]
			req = ret.request[:data]
			req = req.gsub('+', ' ').gsub('%21', '!').gsub('%22', '"').gsub('%28', '(').gsub('%29', ')').gsub('%2A', '*').gsub('%2B', '+').gsub('%2C', ',').gsub('%2F', '/').gsub('%3A', ':').gsub('%3D', '=').gsub('%5B', '[').gsub('%5D', ']').gsub('%5E', '^').gsub('%7B', '{').gsub('%7D', '}')
			ActiveRecord::Base.logger.info("*** SOLR: [#{index}] #{req}")
		end

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
    facets = @facet_fields
    facets = options['facet'] if options['facet'].nil? == false
    options.delete('facet' )

		options = add_facet_param(options, facets) if overrides[:no_facets] == nil

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
				if highlight && highlight['content_ascii']
               str = highlight['content_ascii'].join("\n") # This should always return an array of size 1, but just in case, we won't throw away any items.
               hit['text'] = str.force_encoding("UTF-8")
            end
			}
		end

		facets = facets_to_hash(ret)
		#facets['federation'] = adjust_federation_counts(options, facets['federation'])
		#facets['archive'] = adjust_archive_counts(options, facets['archive'])

    # get the pivots if appropriate and merge with the existing facet section
    pivots = pivots_to_hash( ret )
    facets = merge_pivot_data( facets, pivots )

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

    return( facets )
  end

  def pivots_to_hash( ret )

    # untangle and turn strings to symbols
    pivots = {}
    if ret && ret['facet_counts'] && ret['facet_counts']['facet_pivot']
      ret['facet_counts']['facet_pivot'].each do | pivot_name, results |

        facet_name = pivot_name.split( "," )[ 0 ]
        pivot_name = pivot_name.split( "," )[ 1 ]
        rl = []
        results.each do | pivot |
          pl = []
          pivot['pivot'].each do |p|
             pl.push( { :name => p['field'], :value =>p['value'], :count => p['count']} )
          end
          rl.push( { :name => pivot['field'], :value => pivot['value'], :count => pivot['count'], :pivot => pl } )
        end
        if pivots[ facet_name ].nil?
          pivots[ facet_name ] = []
        end
        pivots[ facet_name ].push( { :name => pivot_name, :value => rl} )
      end
    end

    return pivots if pivots.empty?

    # organize by facet because this is the way the information will be reported
    by_facet = {}
    pivot_major = pivots.keys.first( )
    pivot_list = pivots[ pivot_major ]
    pivot_list.each do | p |
       pivot_minor = p[:name]
       p[:value].each do | f |
          if f[:value].nil? || f[:value].empty?
            next
          end
          if by_facet.has_key?( f[:value] ) == false
             by_facet[ f[:value] ] = { :count => f[:count], pivot_minor => f[:pivot]}
          else
            by_facet[ f[:value] ] = by_facet[ f[:value] ].merge( { pivot_minor => f[:pivot] } )
          end
       end
    end

    return( { pivot_major => by_facet } )
	end

  def merge_pivot_data( facets, pivots )

    # for each facet that we already have, merge in any pivot data
    facets.each do | facet_name, facet_list |
      if pivots.has_key? facet_name
        facet_list.each_index do | ix |
           pivots[ facet_name ].each do | key, pl |
              if key == facet_list[ix][:name]
                count = pl[:count]
                pl.delete( :count )
                facet_list[ix] = { :name => key, :count => count, :pivots => pl }
              end
           end
        end
      end
    end

    # for all the pivots we have that do not have existing facet section, add one and populate
    # as appropriate
    pivots.each do | pivots_name, pivots_list |
      if facets.has_key?( pivots_name ) == false
         pl = []
         pivots_list.each do | key, value |
           count = value[:count]
           value.delete( :count )
           pl.push( { :name => key, :count => count, :pivots => value } )
         end
         facets[ pivots_name ] = pl
      end
    end

    return( facets )
  end

	def modify_object(uri, field, value)
		`curl #{SOLR_URL}/#{@core}/update -H 'Content-type:application/json' -d '[{"uri":"#{uri}","#{field}":{"set":"#{value}"}}]' 2> /dev/null`
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
		solr = RSolr.connect( :url=> SOLR_URL, :read_timeout => 999999, :open_timeout => 200 )
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
