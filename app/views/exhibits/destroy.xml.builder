xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.exhibits do
	xml.text!("\n  ")
	xml.delete "Exhibit deleted: #{@title}"
	xml.text!("\n")
end
