class WhiteListsController < ApplicationController
  before_action :set_white_list, only: [:show, :edit, :update, :destroy]

  # GET /white_lists
  # GET /white_lists.json
  def index
    @white_lists = WhiteList.all
  end

  # GET /white_lists/1
  # GET /white_lists/1.json
  def show
  end

  # GET /white_lists/new
  def new
    @white_list = WhiteList.new
  end

  # GET /white_lists/1/edit
  def edit
  end

  # POST /white_lists
  # POST /white_lists.json
  def create
    @white_list = WhiteList.new(white_list_params)

    respond_to do |format|
      if @white_list.save
        format.html { redirect_to @white_list, notice: 'White list was successfully created.' }
        format.json { render :show, status: :created, location: @white_list }
      else
        format.html { render :new }
        format.json { render json: @white_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /white_lists/1
  # PATCH/PUT /white_lists/1.json
  def update
    respond_to do |format|
      if @white_list.update(white_list_params)
        format.html { redirect_to @white_list, notice: 'White list was successfully updated.' }
        format.json { render :show, status: :ok, location: @white_list }
      else
        format.html { render :edit }
        format.json { render json: @white_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /white_lists/1
  # DELETE /white_lists/1.json
  def destroy
    @white_list.destroy
    respond_to do |format|
      format.html { redirect_to white_lists_url, notice: 'White list was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_white_list
      @white_list = WhiteList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def white_list_params
      params.require(:white_list).permit(:ip, :comment)
    end
end
