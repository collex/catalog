xml.instruct!
xml.federations do
@federations.each do |federation|
	xml.federation do
		xml.name federation[:name]
		xml.thumbnail request.protocol + request.host_with_port + federation.thumbnail.url(:thumb)
		xml.site federation[:site]
	end
end
end
