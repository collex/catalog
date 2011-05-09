class SearchController < ApplicationController
	# GET /searches
	# GET /searches.xml
	def index
		# TODO: Really make the call to get the search results here
		results = [ { :uri => 'http://fake/001', :title => 'System Test' }, { :uri => 'http://fake/002', :title => 'Second Object' }]

		respond_to do |format|
			format.html # index.html.erb
			format.xml  { render :xml => results }
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
			format.xml  { render :xml => @totals }
		end
	end

	# GET /searches/autocomplete
	# GET /searches/autocomplete.xml
	def autocomplete
		# TODO: Really make the call to get the autocomplete here
		results = [  ]

		respond_to do |format|
			format.html # index.html.erb
			format.xml  { render :xml => results }
		end
	end

	# GET /searches/names
	# GET /searches/names.xml
	def names
		# TODO: Really make the call to get the names here
		results = [  ]

		respond_to do |format|
			format.html # index.html.erb
			format.xml  { render :xml => results }
		end
	end

	# GET /searches/1
	# GET /searches/1.xml
	def show
		# TODO: Really make the call to get the document by uri here
#		@search = Search.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml  { render :xml => @search }
		end
	end

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
