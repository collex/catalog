xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.destroy do
	xml.text!("\n  ")
	xml.response "OK"
	xml.text!("\n")
end
