task :ask_production_confirmation do
	set :confirmed, proc {
		puts <<-WARN

    ========================================================================
          WARNING: You're about to deploy to PRODUCTION!!!
    ========================================================================

		WARN
		ask :answer, "Are you sure you want to continue? Type 'yes'"
		if fetch(:answer)== 'yes'
			true
		else
			false
		end
	}.call

	unless fetch(:confirmed)
		puts "\nCancelled!"
		exit
	end
end