$(function() {
	"use strict";

	$('#search-compare').bind('ajax:success', function(xhr, data, status){
		var el = $("#compare-results");
		el.text(data);
	});
});
