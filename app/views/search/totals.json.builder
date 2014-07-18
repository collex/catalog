json.array!(@totals) do |totals|
	json.extract! totals, :federation, :totals, :sites
end
