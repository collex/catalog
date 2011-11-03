class SearchController < ApplicationController
	# GET /searches
	# GET /searches.xml
	def index
		query_params = QueryFormat.catalog_format()
		begin
			QueryFormat.transform_raw_parameters(params)
			query = QueryFormat.create_solr_query(query_params, params)
			is_test = Rails.env == 'test' ? :test : :live
			is_test = :shards if params[:test_index]
			# tank citations
			#if query['q']
			#	query['q'] = "(#{query['q']} -genre:Citation)^20 (#{query['q']} genre:Citation)^0.1"
			#end
			solr = Solr.factory_create(is_test)
			@results = solr.search(query)

			respond_to do |format|
				format.html # index.html.erb
				format.xml
			end
		rescue ArgumentError => e
			render_error(e.to_s)
		rescue SolrException => e
			render_error(e.to_s, e.status())
		end
	end

	# GET /searches/totals
	# GET /searches/totals.xml
	def totals
		is_test = Rails.env == 'test' ? :test : :live
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
			is_test = Rails.env == 'test' ? :test : :live
			is_test = :shards if params[:test_index]
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
			render_error(e.to_s)
		rescue SolrException => e
			render_error(e.to_s, e.status())
		end
	end

	# GET /searches/names
	# GET /searches/names.xml
	def names
		query_params = QueryFormat.names_format()
		begin
			QueryFormat.transform_raw_parameters(params)
			query = QueryFormat.create_solr_query(query_params, params)
			is_test = Rails.env == 'test' ? :test : :live
			is_test = :shards if params[:test_index]
			solr = Solr.factory_create(is_test)
			@results = solr.names(query)

			respond_to do |format|
				format.html # index.html.erb
				format.xml
			end
		rescue ArgumentError => e
			render_error(e.to_s)
		rescue SolrException => e
			render_error(e.to_s, e.status())
		end
	end

	# GET /searches/details
	# GET /searches/details.xml
	def details
		query_params = QueryFormat.details_format()
		begin
			QueryFormat.transform_raw_parameters(params)
			query = QueryFormat.create_solr_query(query_params, params)
			is_test = Rails.env == 'test' ? :test : :live
			is_test = :shards if params[:test_index]
			solr = Solr.factory_create(is_test)
			@document = solr.details(query)

			respond_to do |format|
				format.html # index.html.erb
				format.xml
			end
		rescue ArgumentError => e
			render_error(e.to_s)
		rescue SolrException => e
			render_error(e.to_s, e.status())
		end
	end

end
