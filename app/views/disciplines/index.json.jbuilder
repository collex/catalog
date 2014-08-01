json.array!(@disciplines) do |discipline|
  json.extract! discipline, :id, :name
  json.url discipline_url(discipline, format: :json)
end
