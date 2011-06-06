xml.instruct!
xml.federations do
@federations.each do |federation|
	xml.federation do
		xml.name federation[:name]
		xml.thumbnail federation[:thumbnail]
	end
end
end
