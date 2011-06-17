xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.search do
	xml.text!("\n  ")
	xml.total @results[:total]
	xml.text!("\n  ")
	xml.total_documents @results[:total_documents]
	xml.text!("\n  ")
	xml.results do
		@results[:hits].each do |result|
			xml.text!("\n    ")
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
				xml.text!("\n    ")
			end
		end
		xml.text!("\n  ")
	end
	xml.text!("\n")
end