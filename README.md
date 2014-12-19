# Collex Catalog

The collex catalog is the backend that provides a public interface to the 
documents stored in solr. You only need to set this up if you are not adding 
your Federation to the ones in ARC, but you are setting up a completely 
independent copy of the whole collex tool chain.

# Collex architecture

Collex is a complex project made up of a number of subprojects that all have to
be in place for it to work. Most users will probably just need to set up the 
main Collex piece and point it at the existing Catalog. If that is all you want
to do, then you don't need to understand the following architecture and you 
don't need to download the "solr" or "catalog" projects.

When Collex is deployed, it is branded with the name of a particular 
"Federation", like NINES or 18thConnect. The website that the end user goes to 
will look like that federation, but the code behind it is the "collex" 
project here.

When a search is done from "collex", the request is made to the "catalog" 
project, which is a web service that exposes all the documents that have been 
stored.

The "catalog" webservice processes the request and forms the correct call to 
the "solr" webservice.

The "arc-inbox" is a simple website that allows users to upload new .rdf 
content that will be added to the catalog / solr index.

The documents are added to the solr index by converting RDF documents using 
the project "rdf-indexer".

The About section of "collex" and the News section of "collex" are two separate
WordPress installations. The recommended theme to use is in the 
"collex_wordpress_theme" project.

The "typewright" project can be attached to a "collex" instance if you wish by 
setting it up in the site.yml file of "collex". The "typewright" project is a 
webservice that keeps the information about all the typewright-enabled
documents. The actual web presence of typewright is in the "collex" project 
under subfolders named typewright.

# Indexing

All of the indexing is handled by executing rake tasks from the Catalog directory.
The general workflow for indexing is as follows:

Test the new RDF and see if it is error-free with this command:

    rake solr_index:archive_test archive=name

If results are good, these files can be indexed into a testing index with this:

    rake solr_index:index_and_test archive=name

 -- or --

    rake solr_index:index archive=name

The first command will index the archive and run some comparisons against pre-existing
data in the main index. The second skips these tests.

An archive that has passed through this process will be indexed, but reside in a testing
index. To view it collex requires an admin user. Log in to collex and access the admin
page. On it is a link that allows temporary use of the testing index, Click it. From that
point on, the testing index will be used for all searching. Be sure to reverse this
setting once testing is done.

Once you are satisfied that the newly indexed archive is good, it must be merged into the
main index. This is done by executing:

    rake solr_index:merge_archive archive=name

When it completes, the new archive will be part of the main index.

# Indexing special case

The ECCO archive is a special case archive. Many of the documents within it are 
typewright enabled. The default indexing process described above does not set the
typewright flag. To make this setting correct, an extra rake task must be run
after the initial index command. It is as follows:

    rake ecco:typewright_enable file=ecco_tw_enabled.txt


Once complete, all documents that are tryewright enabled will be marked as such, and
can be merged into the main index.

# Local Install

1. Download this project to your local development area.
2. Copy config/database.example.yml to config/database.yml.
3. Copy config/site.example.yml to config/site.yml.
4. Modify those two files to suit your server and your needs. There are comments in them. **DO NOT CHECK THEM IN!**
5. The first time you run, you will have to run `bundle install`.
6. Create and migrate the database with the standard rake commands.
7. If you are running an instance of solar locally, you can control it with `rake solr:start` and `rake solr:stop`.
8. Launch the server with `rails s -p 3001`. This will launch the catalog
   and it will listen for connections on port 3001.
9. To create an admin user for the catalog, run `rake users:create`

# Deployment

The catalog is deployed using capistrano, and can be deployed to either
a staging server (edge) or a production server. The configuration for each
host is found in config/site.yml at the bottom of the file. Fill
in the necessary data for each site. To complete this section, you
must have a user created on the target host which will run the catalog.
That user must have full read/write permissions on the install directory.
Additionally you must generate an ssh key-pair on your development machine and
install it on the target host. Add an entry in your ~/.ssh/config file for
each host. Example:

    Host edge-catalog
       Hostname 128.128,128,128
       User collex
       Port 22
       IdentityFile ~/.ssh/edge-collex


1. First time deployment has a few extra setup steps
  1. Copy Capfile.example to Capfile
  2. Copy config/deploy.rb.example to config/deploy.rb
  3. Modify config/deploy.rb to suit your needs.
  4. Setup common structures on the host, run `cap edge_setup` or `cap prod_setup`
	5. Login to the host and navigate to the install directory.
	6. From there, cd into shared/config.
	7. Fill in the template database.yml and site.yml
	8. Startup mysql and create the database 'collex_catalog_production'
2. After this setup, each subsequent deployment is accomplished by running `cap menu`
	 It will present you with a menu to pick a destination of edge or production
	 After you make the selection, deployment will begin.

# License

> Copyright 2011 Applied Research in Patacriticism
and the University of Virginia

> Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

> Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.