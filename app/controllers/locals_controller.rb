class LocalsController < ApplicationController

  before_filter :check_auth, :only => [:create, :update, :destroy]

	# Since it is so hard to test these calls with capybara, there are a couple fake calls that are just gets.
	# They are only available from localhost, so it isn't a security hole.
	def test_search_good()
		if	request.headers['REMOTE_ADDR'] == '127.0.0.1'
			federation = Federation.find_by({ name: params[:federation] })
			if federation
				request.env['REMOTE_ADDR'] = federation.ip
				index()
			end
		end
	end

	def test_search_bad()
		if	request.headers['REMOTE_ADDR'] == '127.0.0.1'
			index()
		end
	end

	def straighten_out_visible(query)
		visible = query['visible']
		if visible
			visible = visible.gsub("AND", "OR")
			visible = "(#{visible} OR visible_to_everyone:true)"
		else
			visible = "visible_to_everyone:true"
		end
		if query['q']
			query['q'] = query['q'] + " AND " + visible
		else
			query['q'] = visible
		end
		query.delete('visible')
	end

	# GET /locals
	# GET /locals.xml
	def index
		federation = Federation.find_by({ name: params[:federation] })
		ip = request.headers['REMOTE_ADDR']
		if federation && ip == federation.ip
			begin
				query_params = QueryFormat.locals_format()
				QueryFormat.transform_raw_parameters(params)
				query = QueryFormat.create_solr_query(query_params, params, nil)
				query.merge!(QueryFormat.transform_highlight("hl", "on")) if params[:q]
				straighten_out_visible(query)

				is_test = Rails.env == 'test' ? :test : :live
				solr = Solr.factory_create(is_test, federation.name)

				@results = solr.search(query, { :field_list => [ 'key', 'title', 'object_type', 'object_id', 'last_modified' ], :key_field => 'key', :no_facets => true })
				if params[:object_type]
					# now do the same search as if there were no query, just to get the total
					params.delete(:object_type)
					params[:max] = "1"
					QueryFormat.transform_raw_parameters(params)
					query = QueryFormat.create_solr_query(query_params, params, nil)
					straighten_out_visible(query)
					r2 = solr.search(query, { :field_list => [ 'key' ], :key_field => 'key', :no_facets => true })
					@results[:total_documents] = r2[:total]
				else
					@results[:total_documents] = @results[:total]
				end

				respond_to do |format|
					format.html { render :template => '/locals/index' }
					format.xml { render :template => '/locals/index' }
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

# GET /locals/1
# GET /locals/1.xml
#  def show
#    @local = Local.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @local }
#    end
#  end
#
#  # GET /locals/new
#  # GET /locals/new.xml
#  def new
#    @local = Local.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @local }
#    end
#  end
#
#  # GET /locals/1/edit
#  def edit
#    @local = Local.find(params[:id])
#  end

	# POST /locals
	# POST /locals.xml
	def create
		federation = Federation.find_by({ name: params[:federation] })
		ip = request.headers['REMOTE_ADDR']
		if federation && ip == federation.ip
			begin
				query_params = QueryFormat.add_locals_format()
				QueryFormat.transform_raw_parameters(params)
				fields = QueryFormat.create_solr_query(query_params, params, nil)
				fields[:key] = "#{params['object_type']}_#{params['object_id']}"
				fields[:title_sort] = params['title']
				#fields[:content_ascii] = params[:content]

				is_test = Rails.env == 'test' ? :test : :live
				solr = Solr.factory_create(is_test, federation.name)

				commit = params[:commit] == 'immediate'
				if fields['title'].blank? && fields['section'].blank? && fields['text'].blank? # if most of this is blank, then we are actually deleting it.
					@results = solr.remove_object(fields[:key], commit)
				else
					@results = solr.add_object(fields, 1.0, commit)
				end

				respond_to do |format|
					format.html # index.html.erb
					format.xml
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

	# PUT /locals/1
	# PUT /locals/1.xml
	def update
		federation = Federation.find_by({ name: params[:id] })
		ip = request.headers['REMOTE_ADDR']
		if federation && ip == federation.ip
			begin
				is_test = Rails.env == 'test' ? :test : :live
				solr = Solr.factory_create(is_test, federation.name)

				solr.commit()

				respond_to do |format|
					format.html # index.html.erb
					format.xml
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

	# DELETE /locals/1
	# DELETE /locals/1.xml
	def destroy
		federation = Federation.find_by({ name: params[:id] })
		ip = request.headers['REMOTE_ADDR']
		if federation && ip == federation.ip
			begin
				is_test = Rails.env == 'test' ? :test : :live
				solr = Solr.factory_create(is_test, federation.name)
				solr.clear_core()

				respond_to do |format|
					format.html # index.html.erb
					format.xml
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
