xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.genres do
@genres.each do |genre|
	xml.text!("\n  ")
	xml.genre do
		xml.text!("\n    ")
		xml.name genre[:name]
		xml.text!("\n  ")
	end
end
xml.text!("\n")
end
