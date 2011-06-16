xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.federations do
@federations.each do |federation|
	xml.text!("\n  ")
	xml.federation do
		xml.text!("\n    ")
		xml.name federation[:name]
		xml.text!("\n    ")
		xml.thumbnail request.protocol + request.host_with_port + federation.thumbnail.url(:thumb)
		xml.text!("\n    ")
		xml.site federation[:site]
		xml.text!("\n  ")
	end
end
	xml.text!("\n")
end
