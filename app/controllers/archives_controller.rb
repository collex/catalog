class ArchivesController < ApplicationController
   before_action :set_archive, only: [:show, :update, :destroy]

   #	before_filter :must_be_logged_in
   before_filter :must_be_logged_in, :except => [:index]

   def facets
      session[:use_testing_index] ||= false
      @sites_forest = Archive.get_tree()
      is_test = Rails.env == 'test' ? :test : :live
      is_test = :shards if session[:use_testing_index] == true
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

   def toggle_testing
      session[:use_testing_index] = !session[:use_testing_index]
      redraw()
   end

   # GET /archives
   # GET /archives.json
   # GET /archives.xml
   def index
      respond_to do |format|
         format.html {
            facets()
         }
         format.json { render json: { archives: Archive.all }}
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
         if not @archive.carousels.empty?
            item[:carousel_list] = {}
            @archive.carousels.each{ |c|
               item[:carousel_list][c.id] = 1
            }
         end
         render :json => {:item => item,
                       :categories => Archive.get_category_list(),
                       :all_carousels => Carousel.all}
      else
         render :json => {:item => { :handle => params[:id] }, :categories => Archive.get_category_list()}
      end
   end

   # POST /archives
   # POST /archives.json
   # POST /archives.xml
   def create
      @archive = Archive.new(archive_params)

      respond_to do |format|
         if @archive.save
            format.html { redraw() }
            format.json { render :show, status: :created, location: @archive }
            format.xml { render :xml => @archive, :status => :created, :location => @archive }
         else
            format.html { render :action => "new" }
            format.json { render json: @archive.errors, status: :unprocessable_entity }
            format.xml { render :xml => @archive.errors, :status => :unprocessable_entity }
         end
      end
   end

   # PATCH/PUT /archives/1
   # PATCH/PUT /archives/1.json
   # PATCH/PUT /archives/1.xml
   def update
      @archive = Archive.find(params[:id])
      if params[:file]
         src = ""
         if params[:file] == 'upload'
            @archive.carousel_image = params[:archive][:carousel_image]
            @archive.save
            if @archive.errors && @archive.errors.count > 0
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
      #params[:archive][:carousel_include] = 1 if params[:archive][:carousel_include] == 'true'

         respond_to do |format|
            if @archive.update(archive_params)
               if params[:archive][:carousel_list]
                  @archive.carousels.delete_all
                  params[:archive][:carousel_list].to_hash().each { |key, value|
                     if value.downcase == 'true'
                        @archive.carousels << Carousel.find(key)
                     end
                  }
               end
               format.html { redraw() }
               format.json { render :show, status: :ok, location: @archive }
               format.xml { head :ok }
            else
               format.html { redraw() }
               format.json { render json: @archive.errors, status: :unprocessable_entity }
               format.xml { render :xml => @archive.errors, :status => :unprocessable_entity }
            end
         end
      end

   end

   # DELETE /archives/1
   # DELETE /archives/1.json
   # DELETE /archives/1.xml
   def destroy
      @archive.destroy
      respond_to do |format|
         format.html { redraw() }
         format.json { head :no_content }
         format.xml  { head :ok }
      end
   end

   private

   # Use callbacks to share common setup or constraints between actions.
   def set_archive
      @archive = Archive.find(params[:id])
   end

   # Never trust parameters from the scary internet, only allow the white list
   # through.
   def archive_params
      params.require(:archive).permit(:carousel_description, :typ, :name, :parent_id, :handle, :site_url, :thumbnail, :carousel_list)
   end
end
