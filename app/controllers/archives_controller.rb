class ArchivesController < ApplicationController
#	before_filter :must_be_logged_in
	before_filter :must_be_logged_in, :except => [:index]

	def facets
		@sites_forest = Archive.get_tree()
		is_test = Rails.env == 'test' ? :test : :live
		solr = Solr.factory_create(is_test)
		comp = Archive.compare_to_solr(solr)
		@missing_in_db = comp[:missing]
		@extra_in_db = comp[:extra]
		@inaccessible_sites = Archive.get_inaccessible_sites()
	end


	def category_list()
		nodes = Archive.get_category_list()
		render :json => nodes
	end

	def tree
		session[:resource_toggle] ||= {}
		expanded = params[:expanded]
		id = params[:id]
		if expanded == 'true' && id != nil
			session[:resource_toggle][id] = 'open'
		end
		if expanded == 'false' && id != nil
			session[:resource_toggle][id] = 'close'
		end
		render :text => ''	# this is just to keep from getting an error.
	end

	# GET /archives
	# GET /archives.xml
	def index
		respond_to do |format|
			format.html {
				facets()
			}
			format.xml {
				@archives = Archive.all
			}
		end
	end

	def redraw
		facets()
		render :partial => 'edit_site_list', :locals => { :sites_forest => @sites_forest, :missing_in_db => @missing_in_db, :extra_in_db => @extra_in_db, :parent_div => 'edit_site_list', :inaccessible_sites => @inaccessible_sites }
	end

	# GET /archives/1/edit
	def edit
		if params[:id].to_i != 0
			@archive = Archive.find(params[:id])
			item = @archive.attributes
			if @archive.carousel_image_file_name
				item[:carousel_image] = @archive.carousel_image.url(:normal)
			end
			render :json => {:item => item, :categories => Archive.get_category_list()}
		else
			render :json => {:item => { :handle => params[:id] }, :categories => Archive.get_category_list()}
		end
	end

	# POST /archives
  # POST /archives.xml
  def create
    @archive = Archive.new(params[:archive])

    respond_to do |format|
      if @archive.save
        format.html { redraw() }
        format.xml  { render :xml => @archive, :status => :created, :location => @archive }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @archive.errors, :status => :unprocessable_entity }
      end
    end
  end

	# PUT /archives/1
	# PUT /archives/1.xml
	def update
		@archive = Archive.find(params[:id])
		if params[:file]
			src = ""
			if params[:file] == 'upload'
				@archive.carousel_image = params[:archive][:carousel_image]
				@archive.save
				if @archive.errors && @archive.errors.length > 0
					err = ""
					@archive.errors.each { |key,val| err += "#{key}: #{val}"}
					render :text => "ERROR;#{err}"
				else
					src = @archive.carousel_image.url(:normal)
					render :text => "OK;#{src}"
				end
			elsif params[:file] == 'remove'
				@archive.carousel_image = nil
				@archive.save
				render :text => "OK"
			end
		else
			params[:archive][:carousel_include] = 1 if params[:archive][:carousel_include] == 'true'

			respond_to do |format|
				if @archive.update_attributes(params[:archive])
					format.html { redraw() }
					format.xml { head :ok }
				else
					format.html { redraw() }
					format.xml { render :xml => @archive.errors, :status => :unprocessable_entity }
				end
			end
		end
	end

  # DELETE /archives/1
  # DELETE /archives/1.xml
  def destroy
    @archive = Archive.find(params[:id])
    @archive.destroy

    respond_to do |format|
      format.html { redraw() }
      format.xml  { head :ok }
    end
  end
end
