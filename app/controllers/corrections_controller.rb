class CorrectionsController < ApplicationController

  def create
    federation = Federation.find_by_name(params[:federation])
    ip = request.headers['REMOTE_ADDR']
    if federation && ip == federation.ip
      render :text => "Not yet implemented", :status => :not_implemented  
    else
      render :text => "You do not have permission to do this.", :status => :unauthorized 
    end
  end
end
