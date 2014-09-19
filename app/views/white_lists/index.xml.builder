xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.white_lists do
@white_lists.each do |white_list|
	xml.text!("\n  ")
	xml.white_list do
		xml.text!("\n    ")
		xml.name white_list[:ip]
		xml.text!("\n  ")
		xml.name white_list[:comment]
		xml.text!("\n  ")
	end
end
xml.text!("\n")
end
