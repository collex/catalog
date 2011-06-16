xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.error do
	xml.text!("\n  ")
	xml.message @error_msg
	xml.text!("\n  ")
	xml.request @original_request
	xml.text!("\n  ")
	xml.status @status.to_s
	xml.text!("\n")
end
