class SearchesController < ApplicationController
  # GET /searches
  # GET /searches.xml
  def index
	  # indexing use cases (besides indexing an entire index:
	  # add/replace a peer-reviewed exhibit
	  # remove a peer-reviewed exhibit
	  # add/replace a community exhibit, group, cluster, or discussion

	  # the query parameter contains:
	  # q=TERM [general query]
	  # aut=TERM [author query]
	  # ed=TERM [editor query]
	  # pub=TERM [publisher query]
	  # y=TERM [year query]
	  # a=ARCH [archive facet]
	  # g=GENRE [genre facet]
	  # f=FED [federation facet]
	  # o=MOD [other facet]
	  # sort=ORDER,DIR [sorting]
	  # start=zero-based starting item
	  # size=max number of items to return

	  # TERM is an array of:
	  # [+-]alpha or [+-]"alpha alpha"
	  # ARCH is: (cannot be repeated)
	  # [+-]archive_code

	  # content, title, author, editor, publisher, year, archive, genre, modifier, federation
	  # colon
	  # plus, minor, or nothing
	  # term containing no punctuation, but possibly in quotes with spaces
	  #
	  # modifier is fulltext, ocr, freeculture
	  #
	  # content, title, author, editor, publisher have a regular parameter
	  # year must be 4 digits
	  # federation, archive and genre must be from the list of valid ones
	  # modifier takes true or false.
	  #
	  # the return can be an error for a bad string, or a solr error, or an array of results.

	  # also need to request a list of archives, genres and federations
	  # should we also host the federation logos?
	  # The archives should only be returned if their is at least one hit in the federation that requests it.

	  # also need to return the totals (per federation?) [num items, num archives]

	  # also need to sort by (title, relevancy, name, date)

	  # also need to search the user content (community, classroom) (group, exhibit, cluster, discussions, all)
	  # sort by (relevancy, title, most recent)

	  # should the resource info be served here? Seems like it.
	  # Name in Resource Tree:
		# Site URL:
		# Thumbnail:
	  # but not the parent, or whether it is in the carousel.

	  # How will indexing be done? How about testing the index?
	  # Probably a second set up will be used for indexing (like nines.perf is now).
	  # Can that be done with our current interface, or do we need to support the
	  # new web service calls?

	  # there is no choice on the fields that are returned: they are the standard fields (except fulltext)

	  # get_num_docs: need a way to get the total document count in solr, also the total archive count (is this per federation?)

	  # What does federation mean, and, if we leave it like it is, is it acceptable to reindex whenever a new federation is started?

	  # Option to return highlighted snippets or not.

	  # Autocomplete: this should take all the other search parameters (if they make sense)

	  # name_facet(constraints)

	  # search user content (takes federation as a parameter), search terms q and facet.

	  # returns total hits and facet counts along with an array of hits

	  # get single object by uri (no text)

	  # add object to user_content or full index (pass in federation, too)

	  # need to do commit/optimize on some type of schedule, perhaps. (How about spawning a process to commit
	  # in 15 minutes. If another add comes in when that process is waiting, then a new commit is not needed?)

	  # delete archive (can only done on exhibits if it belongs to your federation (this is for exhibits). To delete an archive because
	  # it is no longer wanted requires ssh.

	  # get archive list: the site and some of the facet_category tables are served here.
	  # archive name, url, description, thumbnail, carousel description, carousel url, carousel image
	  # these will need to be set up with admin login to this web service.

	  # do we need to send emails, other than exception notifications?

	  # do we need daemons for any reasons?

	  # do we need to cache results here, or should that remain on the collex side?

	  # should we host the exhibits here, at least when they are published?
	  
	  results = [ { :uri => 'http://fake/001', :title => 'System Test' }, { :uri => 'http://fake/002', :title => 'Second Object' }]

    respond_to do |format|
      format.html # index.html.erb
	  format.rdf { render :xml => results }
      format.xml  { render :xml => results }
    end
  end

  # GET /searches/1
  # GET /searches/1.xml
  def show
    @search = Search.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @search }
    end
  end

  # GET /searches/new
  # GET /searches/new.xml
  def new
    @search = Search.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @search }
    end
  end

  # GET /searches/1/edit
  def edit
    @search = Search.find(params[:id])
  end

  # POST /searches
  # POST /searches.xml
  def create
    @search = Search.new(params[:search])

    respond_to do |format|
      if @search.save
        format.html { redirect_to(@search, :notice => 'Search was successfully created.') }
        format.xml  { render :xml => @search, :status => :created, :location => @search }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @search.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /searches/1
  # PUT /searches/1.xml
  def update
    @search = Search.find(params[:id])

    respond_to do |format|
      if @search.update_attributes(params[:search])
        format.html { redirect_to(@search, :notice => 'Search was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @search.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /searches/1
  # DELETE /searches/1.xml
  def destroy
    @search = Search.find(params[:id])
    @search.destroy

    respond_to do |format|
      format.html { redirect_to(searches_url) }
      format.xml  { head :ok }
    end
  end
end
