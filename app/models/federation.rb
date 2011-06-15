class Federation < ActiveRecord::Base
	has_attached_file :thumbnail, :styles => { :thumb => "220x80>" }
end
