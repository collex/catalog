module SearchHelper
	def infer_search_columns(results)
		columns = {}
		results.each { |hit|
			hit.each { |col,val|
				columns[col] = true
			}
		}
		ret = []
		columns.each { |key,val|
			ret.push(key)
		}
		return ret
	end

	def get_xml_path(url)
		return url.sub('?', '.xml?') if url.include?('?')
		return url + '.xml'
	end
end
