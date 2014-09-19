class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  protect_from_forgery
	before_filter :dup_params

  PRIVATE_TOKEN =  Rails.application.secrets.authentication['private_token']

	def must_be_logged_in
		unless user_signed_in?
			flash[:alert]  = "Please log in to access that page."
			redirect_to root_path
		end
	end

	def render_error(msg, stat = :bad_request)
		msg = msg[0..msg.index('Backtrace')-1] if msg.include?('Backtrace')
		@error_msg = msg
		ActiveRecord::Base.logger.info "**** ERROR: #{@error_msg}"
		@status = stat
		@original_request = request.fullpath
		respond_to do |format|
			format.html { render :template => '/home/error', :status => @status }
			format.json  { render json: { error_msg: @error_msg, original_request: @original_request, status: @status }, :status => @status }
			format.xml  { render :template => '/home/error', :status => @status }
		end
	end

	def dup_params()
		if !self.kind_of?(ExhibitsController)
			# we need to look at the original query string to see if there are any duplicate parameters.
			# Rails will filter this out so we won't see them if we just look at params[]
			qs = request.query_string
			arr = qs.split('&')
			p = {}
			arr.each { |q|
				one = q.split('=')
				if p[one[0]] == nil
					p[one[0]] = one[1]
				else
					render_error("The parameter \"#{one[0]}\" appears twice in \"#{qs}.\"")
				end
			}
		end
  end

  def check_auth
    x_auth_key = request.headers['HTTP_X_AUTH_KEY']
    params_token = params[:private_token]
    auth_token = x_auth_key
    auth_token = params_token if x_auth_key.nil? || x_auth_key.blank?
    return PRIVATE_TOKEN == auth_token
  end

end
