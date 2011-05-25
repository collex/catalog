module HomeHelper
	def example_link(link)
		return link_to(link, link.sub('.xml', ''), { :class => 'example_link' })
	end
end
