xml.instruct!
xml.names do
xml.authors do
@results['role_AUT'].each do |result|
	xml.author do
		xml.name result[:name]
		xml.occurrences result[:count]
	end
end
end
xml.editors do
@results['role_EDT'].each do |result|
	xml.editor do
		xml.name result[:name]
		xml.occurrences result[:count]
	end
end
end
xml.publishers do
@results['role_PBL'].each do |result|
	xml.publisher do
		xml.name result[:name]
		xml.occurrences result[:count]
	end
end
end
end
