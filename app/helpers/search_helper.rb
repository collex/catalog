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

	def make_xml_path(url)
		return raw("<a href=\"#{get_xml_path(request.fullpath)}\" class=\"xml_path\">See these results as XML</a>")
	end

	def make_home_path()
		return raw("<div class=\"home_link\">#{link_to raw("&larr; Home"), home_index_path}</div>")
	end
end
