xml = Builder::XmlMarkup.new
xml.instruct!
xml.text!("\n")
xml.languages do
	xml.text!("\n  ")
  @results['language'].each do |result|
    xml.text!("\n    ")
    xml.language do
      xml.text!("\n      ")
      xml.name result[:name]
      xml.text!("\n      ")
      xml.occurrences result[:count]
      xml.text!("\n    ")
    end
  end
	xml.text!("\n")
end
