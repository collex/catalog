xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.search do
	xml.text!("\n  ")
	xml.total @results[:total]
	xml.text!("\n  ")
	xml.results do
		xml.text!("\n    ")
		@results[:hits].each do |result|
			xml.result do
				result.each do |key,value|
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
				xml.text!("\n  ")
			end
			xml.text!("\n\n  ")
		end
		xml.text!("\n  ")
	end
	xml.text!("\n  ")
	xml.facets do
		@results[:facets].each do |facet_name, facet_list|
			xml.text!("\n    ")
			xml.tag!(facet_name) {
				facet_list.each do |facet|
					xml.text!("\n      ")
					xml.facet do
						xml.text!("\n        ")
						xml.name facet[:name]
						xml.text!("\n        ")
						xml.count facet[:count]
						xml.text!("\n      ")
					end
				end
				xml.text!("\n    ")
			}
			xml.text!("\n  ")
		end
		xml.text!("\n  ")
	end
	xml.text!("\n")
end
