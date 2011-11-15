xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.exhibits do
	@exhibits.each do |exhibit|
		xml.text!("\n    ")
		xml.uri exhibit
	end
	xml.text!("\n  ")
end
