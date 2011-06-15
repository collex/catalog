class ApplicationController < ActionController::Base
	protect_from_forgery
	before_filter :dup_params

	def must_be_logged_in
		unless user_signed_in?
			flash[:alert]  = "Please log in to access that page."
			redirect_to root_path
		end
	end

	def render_error(msg, stat = :bad_request)
		msg = msg[0..msg.index('Backtrace')-1] if msg.include?('Backtrace')
		@error_msg = msg
		puts "**** ERROR: #{@error_msg}"
		@status = stat
		@original_request = request.fullpath
		respond_to do |format|
			format.html { render :template => '/home/error', :status => @status }
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
end
