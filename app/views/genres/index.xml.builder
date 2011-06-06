xml.instruct!
xml.genres do
@genres.each do |genre|
	xml.genre do
		xml.name genre[:name]
	end
end
end
