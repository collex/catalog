/*global YUI */

// If the browser supports the HTML5 history mechanism, then all links will actually be ajax calls, handled
// through this. If the browser doesn't support it, then the links are normal.
//
// This assumes that there is a div with the id "everything" that should receive all the updates.
// This assumes that all of the links that are intended for the server contain the class "json_link".
// This assumes that all of the server calls support the link requested as a POST as well as GET.
// This fires the global event "history:pageChange" whenever it changes a page.
//
// This caches responses, so we don't need to return to the server to get a page we have already retrieved.
//
// This responds to the global event "history:triggerChange", so other javascript files can use this mechanism by
// calling: Y.Global.fire('history:triggerChange', href);

YUI().use('node', 'history', 'io-base', 'querystring-stringify-simple', function (Y) {
	// Find out if the browser supports this.
	var isSupported = Y.History === Y.HistoryHTML5;
	var debugLog = false;
	function consoleLog(str) {
		if (debugLog) console.log(str);
	}

	// If the browser supports this, then set up the page for using this.
	if (isSupported) {
		// Utility functions to handle the url's parameters
		var parseParams = function(href) {
			var data = {};
			var i = href.indexOf('?');
			var args = href.substring(i+1).split('&');
			for (var j = 0; j < args.length; j++) {
				var arr = args[j].split('=');
				data[arr[0]] = arr[1];
			}
			return data;
		};

		var strippedUrl = function(href) {
			var i = href.indexOf('?');
			var url = (i > 0) ? href.substring(0, i) : href;
			return url;
		};

		var addCsrf = function(data) {
			var csrf_param = Y.one('meta[name=csrf-param]');
			csrf_param = csrf_param.get('content');
			var csrf_token = Y.one('meta[name=csrf-token]');
			csrf_token = csrf_token.get('content');

			data[decodeURIComponent(csrf_param)] = decodeURIComponent(csrf_token);
			return data;
		};

		// Cache of the pages that we've already visited.
		var siteHistory = {};
		var scrollHistory = {};
		var lastPage = null;

		var history = new Y.HistoryHTML5();

		var snapshotOldPage = function(href) {
			consoleLog("snapshotOldPage("+lastPage+")");
			if (lastPage) {
				var x = Y.DOM.docScrollX();
				var y = Y.DOM.docScrollY();
				scrollHistory[lastPage] = { x: x, y: y};

				var el = Y.one("#everything");
				siteHistory[lastPage] = el._node.innerHTML;
			}
			lastPage = href;
		};

		var setPage = function(href) {
			consoleLog("setPage("+href+")");
			snapshotOldPage(href);

			var el = Y.one("#everything");
			el._node.innerHTML = siteHistory[href];
			if (scrollHistory[href])
				window.scroll(scrollHistory[href].x,scrollHistory[href].y);
			Y.Global.fire('history:pageChange', href, parseParams(href));
		};

		var onSuccess = function(id, o, arg) {
			consoleLog("onSuccess");
			siteHistory[arg] = o.responseText;
			scrollHistory[arg] = { x: 0, y: 0 };
			setPage(arg);
		};
		var onFailure = function(id, o, arg) {
			consoleLog("onFailure");
			var el = Y.one("#everything");
			el._node.innerHTML = "There was an error retrieving this page.<br />" +
				"Please use the reload button on your browser to correct this problem.<br />" +
				"ERROR: " + o.status + "<br />" + o.responseText;
		};

		var getDomain = function(url) {
			// Strip off the http://, then get everything to the first /
			var arr = url.split('//');
			if (arr.length !== 2)
				return "";
			arr = arr[1].split('/');
			return arr[0];
		};

		var ajaxRequestPage = function(href) {
			// Make the request to the server -- it is the same request that would have been sent without the
			// ajax, except we'll change it to a POST so that the server can tell the difference.
			var data = parseParams(href);
			data = addCsrf(data);

			consoleLog("ajaxRequestPage");
			Y.io(strippedUrl(href), { method: 'POST', data: data, on: { success: onSuccess, failure: onFailure }, arguments: href });
		};

		var doCallback = function(target) {
			var href = target._node.href;
			var chg_history = target.hasClass('json_history');
			consoleLog("doCallback("+href+")");

			// See if it is the same domain - we aren't allowed to do this if it is cross-domain.
			var requestDomain = getDomain(href);
			var currDomain = getDomain(location.href);
			if (requestDomain !== currDomain)
				return false;

			// Add to the history -- modify the browser back button and save the state.
			if (chg_history) {
				consoleLog("chg_history");
				history.add( { href: href }, { url: href });
			} else {
				consoleLog("NOT chg_history");
				ajaxRequestPage(href);
			}
			return true;	// Cause the normal link processing to be halted, so the browser doesn't change pages on us.
		};

		Y.on('history:change', function (e) {
			consoleLog("history:change");
			var changed = e.changed;
			//var removed = e.removed;

			if (changed.href) {
				var href = changed.href.newVal;
				consoleLog("changed.href= "+href+" "+(siteHistory[href]?"yes":"no"));
				if (siteHistory[href])
					setPage(href);
				else
					ajaxRequestPage(href);
			} else {
				// Don't know what happened, but we don't have the info -- just re-get the page normally to recover.
				consoleLog("NOT changed.href");
				window.location = window.location;
			}
		});

		// Have a public entry point so other javascript can use this
		Y.Global.on('history:triggerChange', function(href) {
			history.add({ href: href }, { url: href });
		}, Y);

		// intercept all links that would go back to the server.
		Y.delegate("click", function(e) {
			consoleLog("onClick");
			if (doCallback(e.target))
				e.halt();
		}, 'body', ".json_link");

		Y.on('load', function() {
			lastPage = window.location.href;
			consoleLog("load: "+lastPage);
			snapshotOldPage(lastPage);
		});
	}
});
