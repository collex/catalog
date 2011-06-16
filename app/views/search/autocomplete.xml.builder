xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.autocomplete do
@results.each do |result|
	xml.text!("\n  ")
	xml.result do
		xml.text!("\n    ")
		xml.item result[:item]
		xml.text!("\n    ")
		xml.occurrences result[:occurrences]
		xml.text!("\n  ")
	end
end
xml.text!("\n")
end
