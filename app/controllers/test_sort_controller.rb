class TestSortController < ApplicationController
	def index
		@p = params['sort']
		if @p
			field = @p['sort']
			sort_fields = { 'Title' => [ 'title_sort', 'title' ], 'Date' => [ 'year_sort', 'year' ], 'Name' => [ 'author_sort', 'author' ] }
			solr = Solr::factory_create(false)
			options = { :q => @p['constraints'], :sort => "#{sort_fields[field][0]} #{@p['dir']}", :rows => @p['rows'], :start => 0 }
			@results = solr.search(options, { :field_list => sort_fields[field], :no_facets => true })
		else
			@p = { 'constraints' => 'has_full_text:true', 'rows' => 100, 'sort' => 'Title', 'dir' => 'asc' }
			@results = { :hits => [], :total => 0}
		end
	end

end
