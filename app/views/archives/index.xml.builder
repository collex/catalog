xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.archives do
@archives.each do |archive|
	xml.text!("\n  ")
	xml.archive do
		xml.text!("\n    ")
		xml.handle archive[:handle]
		xml.text!("\n    ")
		xml.name archive[:name]
		xml.text!("\n    ")
		xml.site_url archive[:site_url]
		xml.text!("\n    ")
		xml.thumbnail archive[:thumbnail]
		xml.text!("\n    ")
		xml.carousel_description archive[:carousel_description]
		xml.text!("\n    ")
		xml.carousel_image_url archive[:carousel_image_url]
		xml.text!("\n  ")
	end
end
xml.text!("\n")
end
