class SolrException < StandardError
	def initialize(msg, status = :internal_server_error)
		@status = status
		super(msg)
	end

	def status()
		return @status
	end
end

