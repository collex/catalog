module HomeHelper
	def example_link(link)
		return link_to(link, link.sub('.xml', ''), { :class => 'example_link' })
	end

	def tab_link(label, value, curr_tab)
		li_opts = {}
		li_opts[:class] = 'selected' if value == curr_tab
		return content_tag(:li,
			link_to(label, "/?tab=#{value}", { :class => "json_link json_history" }),
			li_opts)
	end
end
