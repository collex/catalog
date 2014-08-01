# encoding: UTF-8
##########################################################################
# Copyright 2011 Applied Research in Patacriticism and the University of Virginia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

require "#{Rails.root}/lib/tasks/task_reporter.rb"
require "#{Rails.root}/lib/tasks/task_utilities.rb"

namespace :jstor do
	desc "Create RDF files, given a JSON file; params: [archive,path.json]"
	task :generate_rdf, [:archive,:path] => :environment do |t, args|
		test = false
		start_time = Time.now
		archive = args[:archive]
		path = args[:path]
		folder = File.join(RDF_PATH, 'jstor')
		folder = File.join(folder, archive)
		archive = "jstor#{archive}" if !archive.include?('jstor')
		all = {}
		genres = []
		puts "~~~~~~~~~~~ Generating RDF for #{archive} from #{path} into #{folder}..."
		count = 0
		File.open(path, "r").each_line { |line|
			doc = JSON.parse(line)
			if test
				doc.each { |key, value|
					all[key] = [] if all[key].blank?
					all[key].push(value)
				}
			end
			genre = doc['subject_weights'].present? ? doc['subject_weights'].join('') : ""
			arr = genre.split('|')
			arr.each { |item|
				genres.push(item.split("^")[0])
			}

			uri = doc['doi'].join('')
			out_file_name = uri.gsub(/[^A-Za-z\-0-9]/, '.') + ".rdf"
			out_file_name = File.join(folder, out_file_name)

			File.open(out_file_name, "w") { |file|
				file.puts("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n")
				file.puts("<rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n")
				file.puts("\t xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\"\n")
				file.puts("\txmlns:collex=\"http://www.collex.org/schema#\" xmlns:jstor=\"http://www.jstor.org/fakeschema#\"\n")
				file.puts("\txmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"\n")
				file.puts("\txmlns:role=\"http://www.loc.gov/loc.terms/relators/\">\n\n")

				file.puts("\t<jstor:article rdf:about=\"http://www.jstor.org/stable/#{uri}\">\n")
				file.puts("\t\t<rdfs:seeAlso rdf:resource=\"http://www.jstor.org/stable/#{uri}\"/>\n")
				file.puts("\t\t<collex:archive>#{archive}</collex:archive>\n")
				file.puts("\t\t<collex:federation>NINES</collex:federation>\n")
				file.puts("\t\t<collex:freeculture>false</collex:freeculture>\n")
				file.puts("\t\t<collex:fulltext>true</collex:fulltext>\n")

				if doc['article_title'].present?
					title = doc['article_title'].join('').gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
				elsif doc['reviewed_works'].present?
					title = "Review: "
					works = []
					doc['reviewed_works'].each {|work|
						works.push(work.split('|')[0])
					}
					title += works.join('; ').gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
				else
					title = ""
				end
				file.puts("\t\t<dc:title>#{title}</dc:title>\n")
				doc['authors'].each { |author|
					str = "#{author['stringname']} #{author['givennames']} #{author['surname']}"
					file.puts("\t\t<role:AUT>#{str.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")}</role:AUT>\n")
				} if doc['authors'].present?
				file.puts("\t\t<role:PBL>#{doc['publishers'].join('').gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")}</role:PBL>\n") if doc['publishers'].present?
				file.puts("\t\t<dc:language>#{doc['languages'].join('')}</dc:language>\n") if doc['languages'].present?

				file.puts("\t\t<collex:genre>Periodical</collex:genre>\n")
				# TODO-PER: other genres

				source = []
				source.push(doc['journal_title'].join('')) if doc['journal_title'].present?
				source.push("Vol. #{doc['volume'].join('')}") if doc['volume'].present?
				source.push("No. #{doc['issue'].join('')}") if doc['issue'].present?
				source.push("pp. #{doc['page_range'].join('')}") if doc['page_range'].present?
				source = source.join(" ")
				file.puts("\t\t<dc:source>#{source.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")}</dc:source>\n")

				file.puts("\t\t<dc:date>\n")
				file.puts("\t\t\t<collex:date>\n")
				file.puts("\t\t\t<rdfs:label>#{doc['cover_date'].join('')}</rdfs:label>\n")
				file.puts("\t\t\t<rdf:value>#{doc['pubyear'].join('')}</rdf:value>\n")
				file.puts("\t\t\t</collex:date>\n")
				file.puts("\t\t</dc:date>\n")

				file.puts("\t\t<collex:text>#{doc['text'].join('').gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")}</collex:text>\n") if doc['text'].present?
				file.puts("\t</jstor:article>\n")
				file.puts("</rdf:RDF>\n")
			}
			count += 1
			print '.' if count % 25 == 0
		}
		puts ""
		if test
			all.each { |key, arr|
				puts "========================================="
				puts "====== #{key} ======"
				puts "========================================="
				arr.uniq!
				arr.each { |value|
					if value.kind_of?(Array)
						value = "ARR: " + value.join(" / ")
					end
					puts value[0..70]
				}
			}
		end
		genres.uniq!
		puts "\n --------------- GENRES --------------"
		puts genres.sort.join("\n")
		finish_line(start_time)
	end

end
