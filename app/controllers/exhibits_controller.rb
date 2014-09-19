class ExhibitsController < ApplicationController

  before_filter :check_auth, :only => [:create, :destroy]

	# This is the way to get exhibits indexed. Only authorized federations can use it.
	#
	# There are two entry points:
	# create (to create or replace an exhibit), and destroy (to remove an exhibit). The exhibit is passed as a hash
	# with all its normal fields, with the exception of "uri" and "archive", which is derived. An additional parameter "id",
	# is sent that the uri and archive are derived from. Also, the field "type=section|whole" must be sent to know now to boost the object.
	#
	# Calling one of these triggers a cron task for doing the commit, since we are expecting more than one change at
	# a time unless the parameter "&commit=immediate" is sent.
	#
	# Authorization is done through a combination of looking at the sender's IP address and the "&federation=XXX"
	# parameter. They have to match.

	# Since it is so hard to test these calls with capybara, there are a couple fake calls that are just gets.
	# They are only available from localhost, so it isn't a security hole.
	def test_create_good()
		if	request.headers['REMOTE_ADDR'] == '127.0.0.1'
			federation = Federation.find_by({ name: params[:federation] })
			if federation
				request.env['REMOTE_ADDR'] = federation.ip
				create()
			end
		end
	end

	def test_create_bad()
		if	request.headers['REMOTE_ADDR'] == '127.0.0.1'
			create()
		end
	end

	def test_destroy_good()
		if	request.headers['REMOTE_ADDR'] == '127.0.0.1'
			federation = Federation.find_by({ name: params[:federation] })
			if federation
				request.env['REMOTE_ADDR'] = federation.ip
				destroy()
			end
		end
	end

	def test_destroy_bad()
		if	request.headers['REMOTE_ADDR'] == '127.0.0.1'
			destroy()
		end
	end

	# GET /exhibits
	# GET /exhibits.xml
	def index
		if params[:format] != 'xml'
			render_error("Must call this through the web service", :forbidden)
		else
			federation = Federation.find_by({ name: params[:federation] })
			ip = request.headers['REMOTE_ADDR']
			if federation && ip == federation.ip
				begin
					is_test = Rails.env == 'test' ? :test : :live
					solr = Solr.factory_create(is_test)
					uri = QueryFormat.id_to_uri('*').gsub("$[FEDERATION_SITE]$", federation.site).gsub(':', '\\:')
					query = { 'q' => "uri:#{uri}/0", fq: "federation:#{federation.name}", 'rows' => 9999999 }
					results = solr.search(query, { field_list: [ 'uri' ]})
					@exhibits = []
					if !results[:hits].blank?
						results[:hits].each { | hit|
							uri = hit['uri'].gsub(/\/0$/, '')
							@exhibits.push(uri)
						}
					end

					respond_to do |format|
						format.xml { render :template => '/exhibits/index' }
					end
				rescue ArgumentError => e
					render_error(e.to_s)
				rescue SolrException => e
					render_error(e.to_s, e.status())
				rescue Exception => e
					ExceptionNotifier.notify_exception(e, :env => request.env)
					render_error("Something unexpected went wrong.", :internal_server_error)
				end
			else
				render_error("You do not have permission to do this.", :unauthorized)
			end
		end

	end

  # POST /exhibits
  # POST /exhibits.xml
	def create
		if params[:format] != 'xml'
			render_error("Must call this through the web service", :forbidden)
		else
			federation = Federation.find_by({ name: params[:federation] })
			ip = request.headers['REMOTE_ADDR']
			if federation && ip == federation.ip
				begin
					query_params = QueryFormat.exhibit_format()
					QueryFormat.transform_raw_parameters(params)
					query = QueryFormat.create_solr_query(query_params, params, nil)

          # remove quotes surrounding values,  quotes are not needed when updating solr with xml
          query.each {|key,val| val.class == String ? val.gsub!(/(^")|("$)/, '') : val}

					page = params[:page]
					query['archive'] = QueryFormat.id_to_archive(query['archive']).gsub("$[FEDERATION_NAME]$", federation.name)
					query[:uri] = query[:uri].gsub("$[FEDERATION_SITE]$", federation.site).gsub("$[PAGE_NUM]$", page ? "/#{page}" : "")
					#query[:archive] = QueryFormat.id_to_archive(id).gsub("$[FEDERATION_NAME]$", federation.name)
					archive_url = query['archive_url']
					archive_name = query['archive_name']
					archive_thumbnail = query['archive_thumbnail']
					query.delete('archive_url')
					query.delete('archive_name')
					query.delete('archive_thumbnail')
					query['genre'] = query['genre'].split(';') if !query['genre'].blank? && query['genre'].include?(';')
					query['discipline'] = query['discipline'].split(';') if !query['discipline'].blank? && query['discipline'].include?(';')
					query['doc_type'] = "Interactive Resource"
					commit = params[:commit] == 'immediate'
					type = params[:type]
					boost = type == 'partial' ? 3.0 : 2.0
					@uri = query[:uri]
					query['freeculture'] = true
					query['has_full_text'] = true

					is_test = Rails.env == 'test' ? :test : :live



					solr = Solr.factory_create(is_test)
					solr.add_object(query, boost, commit)

					if type == 'whole'
						parent_name = "#{federation.name} Exhibits"
						parent = Archive.find_by({ name: parent_name })
						if parent == nil
							parent = Archive.create({ typ: 'node', parent_id: 0, name: parent_name})
						end
						archive = Archive.find_by({ handle: query['archive'] })
						rec = { typ: 'archive', parent_id: parent.id, handle: query['archive'], name: archive_name, site_url: archive_url, thumbnail: archive_thumbnail }
						if archive
							archive.update_attributes(rec)
						else
							Archive.create(rec)
						end
					end

					respond_to do |format|
						format.xml { render :template => '/exhibits/create' }
					end
				rescue ArgumentError => e
					render_error(e.to_s)
				rescue SolrException => e
					render_error(e.to_s, e.status())
				rescue Exception => e
					ExceptionNotifier.notify_exception(e, :env => request.env)
					render_error("Something unexpected went wrong.", :internal_server_error)
				end
			else
				render_error("You do not have permission to do this.", :unauthorized)
			end
		end
	end

  # DELETE /exhibits/1
  # DELETE /exhibits/1.xml
	def destroy
		if params[:format] != 'xml'
			render_error("Must call this through the web service", :forbidden)
		else
			federation = Federation.find_by({ name: params[:federation] })
			ip = request.headers['REMOTE_ADDR']
			if federation && ip == federation.ip
				begin
					commit = params[:commit] == 'immediate'
					id = params[:id]
					uri = QueryFormat.id_to_uri(id).gsub("$[FEDERATION_SITE]$", federation.site).gsub(':', '\\:').gsub('/', '\\/')

					is_test = Rails.env == 'test' ? :test : :live
					solr = Solr.factory_create(is_test)
					solr.remove_exhibit(uri, commit)

					#node = Archive.find_by_handle(archive)
					#node.destroy if !node.blank?
						
					respond_to do |format|
						format.xml { render :template => '/exhibits/destroy' }
					end
				rescue ArgumentError => e
					render_error(e.to_s)
				rescue SolrException => e
					render_error(e.to_s, e.status())
				rescue Exception => e
					ExceptionNotifier.notify_exception(e, :env => request.env)
					render_error("Something unexpected went wrong.", :internal_server_error)
				end
			else
				render_error("You do not have permission to do this.", :unauthorized)
			end
		end
	end
end
