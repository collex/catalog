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
});
