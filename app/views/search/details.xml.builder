xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.search do
	xml.text!("\n  ")
	xml.total '1'
	xml.text!("\n\n  ")
	xml.results do
		xml.text!("\n    ")
		xml.result do
			@document.each do |key,value|
				xml.text!("\n      ")
				xml.tag!(key) {
					if value.kind_of?(Array)
						value.each { |val|
							xml.value val
						}
					else
						xml.text! value.to_s
					end
				}
			end
			xml.text!("\n    ")
		end
		xml.text!("\n  ")
	end
	xml.text!("\n\n  ")
	xml.facets do
		xml.text!("\n    ")
		xml.genre
		xml.text!("\n    ")
		xml.archive
		xml.text!("\n    ")
		xml.freeculture
		xml.text!("\n    ")
		xml.has_full_text
		xml.text!("\n    ")
		xml.federation
		xml.text!("\n    ")
		xml.typewright
		xml.text!("\n  ")
	end
	xml.text!("\n")
end
