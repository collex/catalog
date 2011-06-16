xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.names do
	xml.text!("\n  ")
xml.authors do
@results['role_AUT'].each do |result|
	xml.text!("\n    ")
	xml.author do
		xml.text!("\n      ")
		xml.name result[:name]
		xml.text!("\n      ")
		xml.occurrences result[:count]
		xml.text!("\n    ")
	end
end
	xml.text!("\n  ")
end
	xml.text!("\n\n  ")
xml.editors do
@results['role_EDT'].each do |result|
	xml.text!("\n    ")
	xml.editor do
		xml.text!("\n      ")
		xml.name result[:name]
		xml.text!("\n      ")
		xml.occurrences result[:count]
		xml.text!("\n    ")
	end
end
	xml.text!("\n  ")
end
	xml.text!("\n\n  ")
xml.publishers do
@results['role_PBL'].each do |result|
	xml.text!("\n    ")
	xml.publisher do
		xml.text!("\n      ")
		xml.name result[:name]
		xml.text!("\n      ")
		xml.occurrences result[:count]
		xml.text!("\n    ")
	end
end
	xml.text!("\n  ")
end
	xml.text!("\n")
end
