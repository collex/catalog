xml.instruct!
xml.federations do
@federations.each do |federation|
	xml.federation do
		xml.name federation[:name]
		xml.thumbnail federation[:thumbnail]
		xml.site federation[:site]
	end
end
end
