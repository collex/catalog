$(function() {
	"use strict";

	$('#search-compare').bind('ajax:success', function(xhr, data, status){
		var html = "<table><tr><th colspan='3'>Levenshtein 0</th><th colspan='3'>Levenshtein 1</th><th colspan='3'>Levenshtein 2</th></tr>";
		html += "<tr><th>Exact (" + data.exact[0].total + ")</th><th>Stemmed (" + data.stemmed[0].total + ")</th><th>No Diacriticals (" + data.no_diacriticals[0].total + ")</th>";
		html += "<th>Exact (" + data.exact[1].total + ")</th><th>Stemmed (" + data.stemmed[1].total + ")</th><th>No Diacriticals (" + data.no_diacriticals[1].total + ")</th>";
		html += "<th>Exact (" + data.exact[2].total + ")</th><th>Stemmed (" + data.stemmed[2].total + ")</th><th>No Diacriticals (" + data.no_diacriticals[2].total + ")</th></tr>";
		var biggest = Math.max(data.exact[0].hits.length, data.stemmed[0].hits.length, data.no_diacriticals[0].hits.length, data.exact[1].hits.length, data.stemmed[1].hits.length, data.no_diacriticals[1].hits.length, data.exact[2].hits.length, data.stemmed[2].hits.length, data.no_diacriticals[2].hits.length);
		for (var i = 0; i < biggest; i++) {
			html += "<tr><td>";
			if (data.exact[0].hits.length > i)
				html += data.exact[0].hits[i];
			html += "</td><td>";
			if (data.stemmed[0].hits.length > i)
				html += data.stemmed[0].hits[i];
			html += "</td><td>";
			if (data.no_diacriticals[0].hits.length > i)
				html += data.no_diacriticals[0].hits[i];
			html += "</td><td>";
			if (data.exact[1].hits.length > i)
				html += data.exact[1].hits[i];
			html += "</td><td>";
			if (data.stemmed[1].hits.length > i)
				html += data.stemmed[1].hits[i];
			html += "</td><td>";
			if (data.no_diacriticals[1].hits.length > i)
				html += data.no_diacriticals[1].hits[i];
			html += "</td><td>";
			if (data.exact[2].hits.length > i)
				html += data.exact[2].hits[i];
			html += "</td><td>";
			if (data.stemmed[2].hits.length > i)
				html += data.stemmed[2].hits[i];
			html += "</td><td>";
			if (data.no_diacriticals[2].hits.length > i)
				html += data.no_diacriticals[2].hits[i];
			html += "</td></tr>";
		}
		html += "</table>";
		var el = $("#compare-results");
		el.html(html);
	});
});
