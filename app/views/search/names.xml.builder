xml.instruct!
xml.names do
@results[:author].each do |result|
	xml.author do
		xml.result do
			xml.item result[:item]
			xml.occurrences result[:occurrences]
		end
	end
end
@results[:editor].each do |result|
	xml.editor do
		xml.result do
			xml.item result[:item]
			xml.occurrences result[:occurrences]
		end
	end
end
@results[:publisher].each do |result|
	xml.author do
		xml.result do
			xml.item result[:item]
			xml.occurrences result[:occurrences]
		end
	end
end
end
