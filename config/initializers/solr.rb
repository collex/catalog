# Initialize solr, for starting/stopping, retrieving, and indexing

SOLR_CORE_PREFIX = Rails.application.secrets.solr['core_prefix']
SOLR_URL = Rails.application.secrets.solr['url']
SOLR_PATH = Rails.application.secrets.solr['path']
RDF_PATH = Rails.application.secrets.folders['rdf']
MARC_PATH = Rails.application.secrets.folders['marc']
ECCO_PATH = Rails.application.secrets.folders['ecco']
INDEXER_PATH = Rails.application.secrets.folders['rdf_indexer']
TAMU_KEY =  Rails.application.secrets.folders['tamu_key']
