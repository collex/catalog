class SearchController < ApplicationController
	# GET /searches
	# GET /searches.xml
	def index
		query_params = QueryFormat.catalog_format()
		begin
			QueryFormat.transform_raw_parameters(params)
			query = QueryFormat.create_solr_query(query_params, params)
			is_test = Rails.env == 'test'
			solr = Solr.factory_create(is_test)
			@results = solr.search(query)

			respond_to do |format|
				format.html # index.html.erb
				format.xml
			end
		rescue ArgumentError => e
			respond_to do |format|
				format.html { render :text => e.to_s, :status => :bad_request  }
				format.xml  { render :xml => [ { :error => e.to_s}], :status => :bad_request }
			end
		rescue RSolr::Error::Http => e
			msg = e.to_s
			msg = msg[0..msg.index('Backtrace')-1] if msg.include?('Backtrace')
			respond_to do |format|
				format.html { render :text => msg, :status => :bad_request  }
				format.xml  { render :xml => [ { :error => msg}], :status => :internal_server_error }
			end
		end
	end

	# GET /searches/totals
	# GET /searches/totals.xml
	def totals
		is_test = Rails.env == 'test'
		@totals = Solr.get_totals(is_test)
#		results = [ { :name => 'NINES', :total_docs => 400, :total_archives => 12}, { :name => '18thConnect', :total_docs => 800, :total_archives => 24 } ]

		respond_to do |format|
			format.html # index.html.erb
			format.xml  # index.xml.builder
		end
	end

	# GET /searches/autocomplete
	# GET /searches/autocomplete.xml
	def autocomplete
		query_params = QueryFormat.autocomplete_format()
		begin
			QueryFormat.transform_raw_parameters(params)
			query = QueryFormat.create_solr_query(query_params, params)
			is_test = Rails.env == 'test'
			solr = Solr.factory_create(is_test)
			max = query['max'].to_i
			query.delete('max')
			words = solr.auto_complete(query)
			words.sort! { |a,b| b[:count] <=> a[:count] }
			words = words[0..(max-1)]
			@results = words.map { |word|
				{ :item => word[:name], :occurrences => word[:count] }
			}

			respond_to do |format|
				format.html # index.html.erb
				format.xml
			end
		rescue ArgumentError => e
			respond_to do |format|
				format.html { render :text => e.to_s, :status => :bad_request  }
				format.xml  { render :xml => [ { :error => e.to_s}], :status => :bad_request }
			end
		rescue RSolr::Error::Http => e
			msg = e.to_s
			msg = msg[0..msg.index('Backtrace')-1] if msg.include?('Backtrace')
			respond_to do |format|
				format.html { render :text => msg, :status => :bad_request  }
				format.xml  { render :xml => [ { :error => msg}], :status => :internal_server_error }
			end
		end
	end

	# GET /searches/names
	# GET /searches/names.xml
	def names
		# TODO: Really make the call to get the names here
#		results = { 'author' => [ { :name => 'elliot', :count => '100' }, { :name => 'whitman', :count => '5' }, { :name => 'poe', :count => '34' } ],
#					'editor' => [{ :name => 'elliot', :count => '100' }, { :name => 'whitman', :count => '5' }, { :name => 'poe', :count => '34' }],
#					'publisher' => [{ :name => 'elliot', :count => '100' }, { :name => 'whitman', :count => '5' }, { :name => 'poe', :count => '34' }] }
		query_params = QueryFormat.names_format()
		begin
			QueryFormat.transform_raw_parameters(params)
			query = QueryFormat.create_solr_query(query_params, params)
			is_test = Rails.env == 'test'
			solr = Solr.factory_create(is_test)
			@results = solr.names(query)

			respond_to do |format|
				format.html # index.html.erb
				format.xml
			end
		rescue ArgumentError => e
			respond_to do |format|
				format.html { render :text => e.to_s, :status => :bad_request  }
				format.xml  { render :xml => [ { :error => e.to_s}], :status => :bad_request }
			end
		rescue RSolr::Error::Http => e
			msg = e.to_s
			msg = msg[0..msg.index('Backtrace')-1] if msg.include?('Backtrace')
			respond_to do |format|
				format.html { render :text => msg, :status => :bad_request  }
				format.xml  { render :xml => [ { :error => msg}], :status => :internal_server_error }
			end
		end
	end

	# GET /searches/details
	# GET /searches/details.xml
	def details
		uri = params[:uri]

		# TODO: Really make the call to get the document by uri here
#		@search = Search.find(params[:id])
		@id = uri
		results = { 'role_AUT' => [], 'role_EDT' => [], 'role_PBL' => [] }

		respond_to do |format|
			format.html # show.html.erb
			format.xml  { render :xml => results }
		end
	end

#	# GET /searches/1
#	# GET /searches/1.xml
#	def show
##		@search = Search.find(params[:id])
#		@id = params[:id]
#
#		respond_to do |format|
#			format.html # show.html.erb
#			format.xml  { render :xml => @search }
#		end
#	end
#
	# GET /searches/new
	# GET /searches/new.xml
#	def new
#		@search = Search.new
#
#		respond_to do |format|
#			format.html # new.html.erb
#			format.xml  { render :xml => @search }
#		end
#	end
#
#	# GET /searches/1/edit
#	def edit
#		@search = Search.find(params[:id])
#	end
#
#	# POST /searches
#	# POST /searches.xml
#	def create
#		@search = Search.new(params[:search])
#
#		respond_to do |format|
#			if @search.save
#				format.html { redirect_to(@search, :notice => 'Search was successfully created.') }
#				format.xml  { render :xml => @search, :status => :created, :location => @search }
#			else
#				format.html { render :action => "new" }
#				format.xml  { render :xml => @search.errors, :status => :unprocessable_entity }
#			end
#		end
#	end
#
#	# PUT /searches/1
#	# PUT /searches/1.xml
#	def update
#		@search = Search.find(params[:id])
#
#		respond_to do |format|
#			if @search.update_attributes(params[:search])
#				format.html { redirect_to(@search, :notice => 'Search was successfully updated.') }
#				format.xml  { head :ok }
#			else
#				format.html { render :action => "edit" }
#				format.xml  { render :xml => @search.errors, :status => :unprocessable_entity }
#			end
#		end
#	end
#
#	# DELETE /searches/1
#	# DELETE /searches/1.xml
#	def destroy
#		@search = Search.find(params[:id])
#		@search.destroy
#
#		respond_to do |format|
#			format.html { redirect_to(searches_url) }
#			format.xml  { head :ok }
#		end
#	end
end
