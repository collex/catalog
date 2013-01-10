// This controls the tab-like navigation. It toggles showing or hiding a related div.
//
// Expectations:
// The control should look like this:
//		<ul class="nav">
//			<li class="selected"><a href="#overview">Overview</a></li>
//			<li><a href="#totals">Totals</a></li>
//		</ul>
//
// Then there should be matching <div id="tab_whatever" class="individual_tab"> that will be what is hidden and shown.
//
// This css is required (an image with plus and minus stacked on top of each other and a position for the minus image and a class that hides the div.)
//
//.hidden {
//	display: none;
//}

/*global YUI */
YUI().use('node', function(Y) {

	function select(node) {
		// Do two things here: highlight the correct tab, and show the correct info.
		var tab = node.ancestor();
		var href = node.getAttribute("href");
		var target = href.replace('#', '#tab_');

		// highlight the correct tab
		// First hide all the tabs, then show the one selected
		Y.all("ul.nav li").each(function(node) {
			node.removeClass('selected');
		});
		tab.addClass('selected');

		// show the correct info
		var el = Y.one(target);
		if (el) {
			// First hide all the tabs, then show the one selected
			Y.all(".individual_tab").each(function(node) {
				node.addClass('hidden');
			});

			el.removeClass('hidden');
		}
	}

     Y.on("click", function(e) {
        select(e.target);
    }, "ul.nav a");

	var recentHash = "THIS DOES NOT MATCH";
	function initializeStateFromURL() {
		// Just do something if the hash has changed.
		var initialTab = window.location.hash;
		if (initialTab === recentHash)
			return; // Nothing's changed since last polled.
		recentHash = initialTab;

		// In the normal case, the hash will match one of our tabs. Find that tab.
		var elToSelect;
		if (initialTab !== '')
			elToSelect = Y.one("a[href=" + initialTab + "]");

		// If the hash didn't match, in the normal case it was empty, but anyway, just attempt to select
		// the first tab.
		if (elToSelect === undefined)
			elToSelect = Y.one("ul.nav li:first-child a");

		// If we managed to find a tab to select, select it now.
		if (elToSelect)
			select(elToSelect);
	}

	Y.on("domready", function () {
		// If there is already a tag defined, go right to it.
		initializeStateFromURL();
		// then check for a back or forward button being clicked every second.
		setInterval(initializeStateFromURL, 1000);
	});
});
