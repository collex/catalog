# Initialize solr, for starting/stopping, retrieving, and indexing

SOLR_CORE_PREFIX = SITE_SPECIFIC['solr']['core_prefix']
SOLR_URL = SITE_SPECIFIC['solr']['url']
SOLR_PATH = SITE_SPECIFIC['solr']['path']
folders = SITE_SPECIFIC['folders']
if folders
	RDF_PATH = folders['rdf']
	MARC_PATH = folders['marc']
	ECCO_PATH = folders['ecco']
	INDEXER_PATH = folders['rdf_indexer']
	TAMU_KEY =  folders['tamu_key']
end
PRODUCTION_SSH = SITE_SPECIFIC['production']['ssh']
