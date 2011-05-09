module HomeHelper
	def example_link(link)
		return link_to(link, link.sub('.xml', ''))
	end
end
