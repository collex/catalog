module TestSortHelper
	def make_select(name, options, selected)
		html = "<select name=\"#{name}\">"
		options.each { |option|
			value = ""
			label = ""
			if option.kind_of?(Array)
				value = option[0]
				label = option[1]
			else
				value = option
				label = option
			end
			sel = value == selected ? " selected=\"selected\"" : ""
			html += "<option value=\"#{value}\"#{sel}>#{label}</option>"
		}
		html += "</select>"
		return raw(html)
	end
end
