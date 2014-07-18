namespace :users do
	desc 'Create a new user (user=email,password)'
	task :create => :environment do
		param = ENV['user']
		if param == nil || param.length == 0
			puts "Usage: user=email,password"
		else
			arr = param.split(',')
			if arr.length != 2
				puts "Usage: user=email,password"
			else
				user = User.new
				user.email = arr[0]
				user.password = arr[1]
				user.password_confirmation = arr[1]
				user.save!
				if user == nil
					puts "User not created"
				else
					puts "User successfully created"
				end
			end
		end
	end
end
