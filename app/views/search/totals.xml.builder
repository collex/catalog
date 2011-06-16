xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.totals do
@totals.each do |federation|
	xml.text!("\n  ")
	xml.federation do
		xml.text!("\n    ")
		xml.name federation[:federation]
		xml.text!("\n    ")
		xml.total federation[:total]
		xml.text!("\n    ")
		xml.sites federation[:sites]
		xml.text!("\n  ")
	end
end
xml.text!("\n")
end
