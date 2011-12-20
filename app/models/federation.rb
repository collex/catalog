class Federation < ActiveRecord::Base
	has_attached_file :thumbnail, :styles => { :thumb => "220x80>" }

	def self.request_from_federation(ip)
		# This checks to see if the ip address of the caller matches any of the federations.
		fed = Federation.find_by_ip(ip)
		#return false
		return fed != nil
	end
end
