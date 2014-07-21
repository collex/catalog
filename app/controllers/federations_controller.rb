class FederationsController < ApplicationController
  before_action :set_federation, only: [:show, :edit, :update, :destroy]
#	before_filter :must_be_logged_in
	before_filter :must_be_logged_in, :except => [:index]

  # GET /federations
  # GET /federations.json
  # GET /federations.xml
  def index
    @federations = Federation.all
  end

  # GET /federations/1
  # GET /federations/1.json
  # GET /federations/1.xml
  def show
  end

  # GET /federations/new
  # GET /federations/new.xml
  def new
    @federation = Federation.new
  end

  # GET /federations/1/edit
  def edit
  end

  # POST /federations
  # POST /federations.json
  # POST /federations.xml
  def create
    @federation = Federation.new(federation_params)

    respond_to do |format|
      if @federation.save
        format.html { redirect_to @federation, notice: 'Federation was successfully created.' }
        format.json { render :show, status: :created, location: @federation }
        format.xml  { render :xml => @federation, :status => :created, :location => @federation }
      else
        format.html { render :new }
        format.json { render json: @federation.errors, status: :unprocessable_entity }
        format.xml  { render :xml => @federation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /federations/1
  # PATCH/PUT /federations/1.json
  # PATCH/PUT /federations/1.xml
  def update
    respond_to do |format|
      if @federation.update(federation_params)
        format.html { redirect_to @federation, notice: 'Federation was successfully updated.' }
        format.json { render :show, status: :ok, location: @federation }
        format.xml  { head :ok }
      else
        format.html { render :edit }
        format.json { render json: @federation.errors, status: :unprocessable_entity }
        format.xml  { render :xml => @federation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /federations/1
  # DELETE /federations/1.json
  # DELETE /federations/1.xml
  def destroy
    @federation.destroy
    respond_to do |format|
      format.html { redirect_to federations_url, notice: 'Federation was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_federation
      @federation = Federation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def federation_params
      params.require(:federation).permit(:name, :ip, :site, :thumbnail)
    end
end
