xml.instruct!
xml.archives do
@archives.each do |archive|
	xml.archive do
		xml.handle archive[:handle]
		xml.name archive[:name]
		xml.site_url archive[:site_url]
		xml.thumbnail archive[:thumbnail]
		xml.carousel_description archive[:carousel_description]
		xml.carousel_image_url archive[:carousel_image_url]
	end
end
end
