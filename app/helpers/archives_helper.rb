module ArchivesHelper
	def node_toggle(id, up)
		return raw(content_tag(:div, '', { :class => "expander#{ ' contracter' if !up}", 'data-target' => "site_#{id}", 'data-notice-url' => "/archives/tree?id=#{id}" }))
	end

	def site_links(id, name, is_node, no_edit = false)
		return "" if id == 0 || !user_signed_in?
		edit = no_edit ? '' : content_tag(:a, "[edit]", { :href => '#', :class => 'dialog',
			'data-dlg-url' => "/archives/#{id}",
			'data-dlg-method' => 'PUT',
			'data-dlg-type' => is_node ? 'editCategory' : 'editArchive',
			'data-ajax-url' => "/archives/#{id}/edit",
			'data-parent-div' => 'edit_site_list'
			})
		return edit +
			raw("&nbsp;") +
			content_tag(:a, "[delete]", { :href => '#', :class => 'dialog',
				'data-dlg-url' => "/archives/#{id}",
				'data-dlg-method' => 'DELETE',
				'data-dlg-confirm' => "Are you sure you want to delete '#{name}'?",
				'data-dlg-confirm-title' => "Confirm Deletion",
				'data-dlg-confirm-no' => 'Cancel',
				'data-parent-div' => 'edit_site_list'
			})
	end

	def format_node(node, indent, children_hidden)
		return content_tag(:div, { :class => 'row' }) do
			content_tag(:div, raw("#{raw(node_toggle(node[:id], children_hidden))}#{node[:name]}"), { :class=> "left indent#{indent}" }) +
				content_tag(:div, "#{node[:carousel_include] == 1 ? 'Yes' : ''}", { :class => 'middle' }) +
				content_tag(:div, raw(site_links(node[:id], node[:name], true)), { :class => 'right' })
		end
	end

	def format_site(site, indent)
    if site.carousels.exists?
      carousel_names = site.carousels.collect{|c| c.name}.compact.join(', ');
    end
		return content_tag(:div, { :class => 'row' }) do
			content_tag(:div, "#{site[:name]} [#{site[:handle]}]", { :class=> "left indent#{indent}" }) +
				content_tag(:div, "#{site.carousels.exists? ? carousel_names : ' '}", { :class => 'middle' }) +
				content_tag(:div, raw(site_links(site[:id], site[:name], false)), { :class => 'right' })
		end
	end
end
