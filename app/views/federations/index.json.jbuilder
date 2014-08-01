json.array!(@federations) do |federation|
  json.extract! federation, :id, :name, :ip, :site, :thumbnail
  json.url federation_url(federation, format: :json)
end
