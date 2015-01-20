xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.search do
   xml.text!("\n  ")
   xml.results do
      xml.text!("\n    ")
         xml.result do
            @results[:hits].first.each do |key,value|
               xml.text!("\n      ")
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
            xml.text!("\n  ")
         end
      xml.text!("\n  ")
   end
   xml.text!("\n  ")
   xml.facets do
      @results[:facets].each do |facet_name, facet_list|
         xml.text!("\n    ")
         xml.tag!(facet_name) {
            facet_list.each do |facet|
               xml.text!("\n      ")
               xml.facet do
                  xml.text!("\n        ")
                  xml.name facet[:name]
                  xml.text!("\n        ")
                  xml.count facet[:count]
                  xml.text!("\n      ")
            # add pivots if they exist
            if facet[:pivots].nil? == false && facet[:pivots].empty? == false
              xml.pivots do
                facet[:pivots].each do |name, pivots|
                  xml.text!("\n    ")
                  xml.tag!( name ) {
                    pivots.each do |p|
                      xml.tag!( 'value' ) {
                        xml.text!("\n      ")
                        xml.name p[:value]
                        xml.text!("\n      ")
                        xml.count p[:count]
                      }
                      xml.text!("\n      ")
                    end
                  }
                end
              end
            end
               end
            end
            xml.text!("\n    ")
         }
         xml.text!("\n  ")
      end
      xml.text!("\n  ")
   end
   xml.pages do
      xml.text!("\n    ")
      xml.total @results[:pages][:total]
      @results[:pages][:hits].each do |page|
         xml.page do
            xml.text!("\n      ")
            xml.uri page["uri"]
            xml.page_num page["page_num"]
            xml.text page["text"]
         end
         xml.text!("\n\n  ")
      end
      xml.text!("\n  ")
   end
   xml.text!("\n")
end
