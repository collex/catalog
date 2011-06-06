class FederationsController < ApplicationController
#	before_filter :must_be_logged_in
	before_filter :must_be_logged_in, :except => [:index]

  # GET /federations
  # GET /federations.xml
  def index
    @federations = Federation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml
    end
  end

  # GET /federations/1
  # GET /federations/1.xml
  def show
    @federation = Federation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @federation }
    end
  end

  # GET /federations/new
  # GET /federations/new.xml
  def new
    @federation = Federation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @federation }
    end
  end

  # GET /federations/1/edit
  def edit
    @federation = Federation.find(params[:id])
  end

  # POST /federations
  # POST /federations.xml
  def create
    @federation = Federation.new(params[:federation])

    respond_to do |format|
      if @federation.save
        format.html { redirect_to(@federation, :notice => 'Federation was successfully created.') }
        format.xml  { render :xml => @federation, :status => :created, :location => @federation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @federation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /federations/1
  # PUT /federations/1.xml
  def update
    @federation = Federation.find(params[:id])

    respond_to do |format|
      if @federation.update_attributes(params[:federation])
        format.html { redirect_to(@federation, :notice => 'Federation was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @federation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /federations/1
  # DELETE /federations/1.xml
  def destroy
    @federation = Federation.find(params[:id])
    @federation.destroy

    respond_to do |format|
      format.html { redirect_to(federations_url) }
      format.xml  { head :ok }
    end
  end
end
