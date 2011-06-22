class Archive < ActiveRecord::Base
	has_attached_file :carousel_image, :styles => { :normal => '300x300' }
	# to create a cropped image, use :thumb=> "100x100#".
end
