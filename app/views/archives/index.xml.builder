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
				if archive[:carousel_include].to_i == 1
					xml.text!("\n      ")
					xml.carousel do
						if archive.carousel_image?
							xml.image archive.carousel_image.url
							xml.text!("\n        ")
						end
						xml.description archive[:carousel_description]
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
				if archive.carousels.exists?
					xml.text!("\n      ")
					xml.carousel do
						xml.text!("\n        ")
						if archive.carousel_image?
							xml.image archive.carousel_image.url
							xml.text!("\n        ")
						end
						xml.description archive[:carousel_description]
						xml.text!("\n      ")
            xml.federations do
              archive.carousels.each do |carousel|
                xml.federation carousel.name
              end
            end
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
