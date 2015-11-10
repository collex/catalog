xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.resource_tree do
	xml.text!("\n  ")
	xml.nodes do
	@archives.each do |archive|
		if archive[:typ] == 'node'
			xml.text!("\n    ")
			xml.node do
				xml.text!("\n      ")
				xml.name archive[:name]
				if archive[:parent_id].to_i > 0
					xml.text!("\n      ")
					xml.parent Archive.find(archive[:parent_id]).name
				end
				carousel = archive.carousel_data(params['federation'])
				if carousel.present?
					xml.text!("\n      ")
					xml.carousel do
						if carousel[:image].present?
							xml.image carousel[:image]
							xml.text!("\n        ")
						end
						xml.description carousel[:description]
						xml.text!("\n          ")
					end
				end
				xml.text!("\n    ")
			end
		end
	end
	xml.text!("\n  ")
	end

	xml.text!("\n\n  ")
	xml.archives do
	@archives.each do |archive|
		if archive[:typ] == 'archive'
			xml.text!("\n    ")
			xml.archive do
				xml.text!("\n      ")
				xml.name archive[:name]
				xml.text!("\n      ")
				if archive[:parent_id].to_i > 0
					xml.parent Archive.find(archive[:parent_id]).name
					xml.text!("\n      ")
				end
				xml.handle archive[:handle]
				xml.text!("\n      ")
				xml.site_url archive[:site_url]
				xml.text!("\n      ")
				xml.thumbnail archive[:thumbnail]
				carousel = archive.carousel_data(params['federation'])
				if carousel.present?
					xml.text!("\n      ")
					xml.carousel do
						xml.text!("\n        ")
						if carousel[:image].present?
							xml.image carousel[:image]
							xml.text!("\n        ")
						end
						xml.description carousel[:description]
						xml.text!("\n      ")
					end
				end
				xml.text!("\n    ")
			end
		end
	end
	xml.text!("\n  ")
	end
	xml.text!("\n")
end
