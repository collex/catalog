class HomeController < ApplicationController
  def index
	  @query_params = QueryFormat.catalog_format()
	  @autocomplete_params = QueryFormat.autocomplete_format()
	  @names_params = QueryFormat.names_format()
  end

end
