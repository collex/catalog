YUI().use('node', function(Y) {
	var categories = {};

	/////////////////////////////////////////////////////////////////////////////////////////////////////
	// Edit Category
	/////////////////////////////////////////////////////////////////////////////////////////////////////

	var populateEditCategory = function(panel, data)
	{
		populateAddCategory(panel, data.categories);
		panel.setDataOnForm("archive", data.item);
	};

	Y.Global.fire('dialog:registerDialogType', "editCategory",
		{
			title: "Edit Category",
			focus: 'archive_name',
			populate: populateEditCategory,
			validate: validateAddCategory,
			progressMsg: 'Editing Category...',
			width: 500,
			hidden: { 'archive[typ]': 'node' },
			rows: [
				[ { text: 'This is a label that sites and other categories can be attached to.', klass: 'instructions' } ],
				[ { text: 'Category Name:', klass: 'left' }, { input: 'archive[name]', klass: 'right' } ],
				[ { text: 'Parent Category:', klass: 'left' }, { select: 'archive[parent_id]', klass: 'right', options: [ { value: -1, text: 'Loading categories. Please Wait...' } ] } ],
				[ { text: 'Include in Carousel?', klass: 'left' }, { checkbox: 'archive[carousel_include]', klass: 'right' } ],
				[ { text: 'Carousel Description:', klass: 'left' }, { textarea: 'archive[carousel_description]', klass: 'right' } ],
				[ { text: 'Carousel Thumbnail:', klass: 'left' }, { image: 'archive[carousel_thumbnail]', klass: 'right', removeButton: 'Remove Thumbnail', value: " " } ],
			]
		}
	);

	/////////////////////////////////////////////////////////////////////////////////////////////////////
	// Add Category
	/////////////////////////////////////////////////////////////////////////////////////////////////////

	var populateAddCategory = function(panel, category)
	{
		categories = {};
		var select = Y.one("#archive_parent_id");
		select._node.innerHTML = "";
		for (var i = 0; i < category.length; i++) {
			categories[category[i].name] = true;
			select._node.innerHTML += "<option value='" + category[i].value + "'>" + category[i].name + "</option>";
		}
	};

	var validateAddCategory = function(data) {
		// Be sure that the user entered something
		if (data['archive[name]'] === '')
			return "Please enter a name for the category.";

		// Be sure that the user hasn't entered a duplicate name
		var found = categories[data['archive[name]']];
		if (found)
			return "That category name has already been used.";

		return null;
	};

	Y.Global.fire('dialog:registerDialogType', "addCategory",
		{
			title: "Add Category To Resource Tree", 
			focus: 'archive_name',
			progressMsg: 'Adding Category...',
			width: 500,
			populate: populateAddCategory,
			validate: validateAddCategory,
			hidden: { 'archive[typ]': 'node' },
			rows: [
				[ { text: 'This is a label that sites and other categories can be attached to.', klass: 'instructions' } ],
				[ { text: 'Category Name:', klass: 'left' }, { input: 'archive[name]', klass: 'right' } ],
				[ { text: 'Parent Category:', klass: 'left' }, { select: 'archive[parent_id]', klass: 'right', options: [ { value: -1, text: 'Loading categories. Please Wait...' } ] } ]
			]
		}
	);

});
