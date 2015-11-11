$(function() {
	"use strict";

	var form = $('#search-compare');
	var progress = $('#progress-message');

	form.submit(function() {
		form.find("input[type=submit]").attr("disabled", "disabled");
		progress.text("Please wait while all the searches are being collected.");
		return true;
	});

	form.bind('ajax:error', function(xhr, data, status) {
		form.find("input[type=submit]").removeAttr("disabled");
		var msg = data.responseText;
		if (msg.length > 100)
			msg = msg.split("\n")[0];
		if (msg.length > 100)
			msg = msg.substring(0,100);
		progress.text(msg);
	});

	form.bind('ajax:success', function(xhr, data, status){
		var html = "<table><tr><th colspan='3'>Levenshtein 0</th><th colspan='3'>Levenshtein 1</th><th colspan='3'>Levenshtein 2</th></tr>";
		html += "<tr><th>Exact</th><th>Stemmed</th><th>No Diacriticals</th>";
		html += "<th>Exact</th><th>Stemmed</th><th>No Diacriticals</th>";
		html += "<th>Exact</th><th>Stemmed</th><th>No Diacriticals</th></tr>";
		html += "<tr class='totals'><td>" +  data.exact[0].total + "</td><td>" + data.stemmed[0].total + "</td><td>" + data.no_diacriticals[0].total + "</td><td>" +  data.exact[1].total + "</td><td>" + data.stemmed[1].total + "</td><td>" + data.no_diacriticals[1].total + "</td><td>" +  data.exact[2].total + "</td><td>" + data.stemmed[2].total + "</td><td>" + data.no_diacriticals[2].total + "</td></tr>";
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

		form.find("input[type=submit]").removeAttr("disabled");
		progress.text('');
	});
});
