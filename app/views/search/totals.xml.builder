xml.instruct!
xml.totals do
@totals.each do |federation|
	xml.federation do
		xml.name federation[:federation]
		xml.total federation[:total]
		xml.sites federation[:sites]
	end
end
end
