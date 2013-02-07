xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.disciplines do
@disciplines.each do |discipline|
	xml.text!("\n  ")
	xml.discipline do
		xml.text!("\n    ")
		xml.name discipline[:name]
		xml.text!("\n  ")
	end
end
xml.text!("\n")
end
