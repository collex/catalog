xml.instruct!
xml.search do
	xml.total @results[:total]
	xml.results do
		@results[:hits].each do |result|
			xml.result do
				result.each do |key,value|
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
	end
	xml.facets do
		@results[:facets].each do |facet_name, facet_list|
			xml.tag!(facet_name) {
				facet_list.each do |facet|
					xml.facet do
						xml.name facet[:name]
						xml.count facet[:count]
					end
				end
			}
		end
	end
end
