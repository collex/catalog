xml.instruct!
xml.autocomplete do
@results.each do |result|
	xml.result do
		xml.item result[:item]
		xml.occurrences result[:occurrences]
	end
end
end
