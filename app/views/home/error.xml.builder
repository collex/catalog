xml.instruct!
xml.error do
	xml.message @error_msg
	xml.request @original_request
	xml.status @status.to_s
end
