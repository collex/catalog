class PagesController < ApplicationController
   # GET /pages
   # GET /pages.json
   def index
      # Pages searches requires 4 params:
      #    * URI of the document to search
      #    * Q the query string
      #    * START starting results page (not document page)
      #    * MAX max hits to return

      # First, query the resources core to get metadata and facets
      # for the target document URI
      uri = params[:uri]
      solr = Solr.factory_create(:live)
      doc_results = solr.search({:q=>"uri:#{uri}"})

      # Next get page hits within that document. Only params: highlight, query and URI
      page_solr = Solr.factory_create(:pages)
      query =  QueryFormat.transform_highlight("hl", "on")
      query['hl.fl'] = 'content_ascii' # DO THIS OR HIGHLIGHING UNSTEMMED VERSIONS OF WORDS FAILS
      if params.has_key? :q
         q = QueryFormat.transform_query("q", params[:q] )
         query['q'] = "uri:#{uri} #{q['q']}"
      end
      query['start'] = params[:start]
      query['rows'] = params[:max]
      query['sort'] = "page_num asc"
      pages = page_solr.search(query)

      @results = doc_results
      @results[:pages] =  pages
      @results.to_xml

      respond_to do |format|
         format.json { render json: { results: @results } }
         format.xml
      end
   end
end