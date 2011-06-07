xml.instruct!
xml.search do
	xml.total '1'
	xml.results do
		xml.result do
			@document.each do |key,value|
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
		end
	end
	xml.facets do
		xml.genre
		xml.archive
		xml.freeculture
		xml.has_full_text
		xml.federation
		xml.typewright
	end
end
