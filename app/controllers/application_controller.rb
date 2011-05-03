class ApplicationController < ActionController::Base
  protect_from_forgery

	def must_be_logged_in
		unless user_signed_in?
			flash[:alert]  = "Please log in to access that page."
			redirect_to root_path
		end
	end
end
