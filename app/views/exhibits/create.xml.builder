xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.exhibits do
	xml.text!("\n  ")
	xml.create "Exhibit created: #{@uri}"
	xml.text!("\n")
end
