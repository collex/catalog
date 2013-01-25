// This wraps the modal dialog ability so that a dialog can be called with just a properly marked up <a>
//
// The html id "gd_upload_form" is reserved. Do not use it on your page.
// Also do not use any ids elsewhere on the page that you have defined in your data type.
//
//data-dlg-url
//data-dlg-method
//data-dlg-confirm
//data-dlg-confirm-title
//data-dlg-confirm-yes
//data-dlg-confirm-no
//data-dlg-type [must match one of the types registered in js]
//data-ajax-url
//data-parent-div or data-success-callback
//data-ajax-data
//
//If data-dlg-type is defined, then that dialog is displayed.
//If the dialog wasn't specified, a dlg with an error message is displayed.
//If data-dlg-type is not defined, skip to confirm.
//If data-ajax-url is defined then a spinner is shown and the ajax call is made.
//If data-ajax-data is defined, then it should have the format: "key:value;key:value"
//If successful, then the dlg is populated.
//If not successful, then an error message is displayed.
//On submit,
//if data-confirm, the confirmation message is put up.
//if data-parent-div or data-success-callback then it is an ajax call, otherwise it is a regular page change.
//If the div is supplied, then the response from the server is just placed in the div. If a callback is supplied, the callback is called instead.
//
// data types are defined by registering the data type by firing the following event:
//function registerDialogType(name, json) {
//	YUI().use('node', function(Y) {
//		Y.Global.fire('dialog:registerDialogType', name, json);
//	});
//}
//
// "name" is the name that you use in data-dlg-type, and "json" is what defines the dialog.
// The format of the json is:
//			title: the title that appears at the top of the dialog
//			focus: the element that should initially have the keyboard focus
//			populate: a function that will be called as soon as the data has been retrieved from an ajax call
//			validate: a function that will be called when the user clicks "ok"
//			progressMsg: the message that will appear when the call is being made to the server
//			width: the width of the dialog
//			klass: a class to apply to the entire dialog
//			hidden: a hash containing any data that should be included in the call, but is hidden from the user.
//			rows: an array of all the rows in the dialog
//			each row is an array of items that will appear horizontally. Those items are hashes and can contain:
//				(except for the text type, the value is what will appear in the name attribute. The id will be calculated from that, also.)
//				the type is defined as whichever of these keys is present:
//				text: a span is created with whatever the value of this is.
//				readonly: an input control of type 'text' with 'readonly' set.
//				input: an input control of type 'text'
//				checkbox: an input control of type 'checkbox'
//				textarea: a textarea
//				select: a select control (see below)
//				image: a complex object that displays and allows the modification of an image. (see below)
//
//			each of the items can contain the key 'klass', which causes that class to be added as an attribute.
//
//			the select type also takes the following parameters:
//				options: an array of hashes. The hashes contain { value: and text: } and that is how the <options> are created.
//
//			the image type also contains the attributes:
//				alt: the alt text for the image
//				removeButton: if it exists, a remove button is included and has the specified text.
//			The image type also defines two more server calls: the same URL and method that is specified for the entire
//			dialog, plus either "?file=upload" or "?file=remove".
//

/*global YUI */
YUI().use('node', "panel", "io-base", 'querystring-stringify-simple', 'json-parse', "io-upload-iframe", function(Y) {
	var dlgTypes = {};

	Y.Global.on('dialog:registerDialogType', function(name, data) {
		dlgTypes[name] = data;
	});

	function mergeHashes(dst, src, srcOverrides) {
		for (var property in src)
			if (src.hasOwnProperty(property)) {
				if (dst[property] === undefined || srcOverrides)
					dst[property] = src[property];
			}
		return dst;
	}

	function setDataOnForm(idPrefix, data) {
		for (var property in data) {
			if (data.hasOwnProperty(property)) {
                if (typeof(data[property]) == 'object') {
                    setDataOnForm(idPrefix+'_'+property, data[property])
                }
				var el = Y.one('#'+ idPrefix+ '_'+property);
				if (el) {
					var node = el._node;
					if (node.nodeName === 'SELECT') {
						for (var i = 0; i < node.options.length; i++) {
							if (node.options[i].value === "" + data[property])
								node.selectedIndex = i;
						}
					} else if (node.nodeName === 'TEXTAREA') {
						node.innerHTML = data[property];
					} else if (node.nodeName === 'INPUT' && node.type === 'checkbox') {
						node.checked = data[property];
					} else if (node.nodeName === 'INPUT' && node.type === 'text') {
						node.value = data[property];
					} else if (node.nodeName === 'IMG') {
						node.src = data[property];
					}
				}
			}
		}
	}

	function getAuthenticityToken() {
		var el = Y.one('meta[name=csrf-param]');
		var csrf_param = el._node.content;
		var csrf_token = Y.one('meta[name=csrf-token]')._node.content;
		var ret = { };
		ret[csrf_param] = csrf_token;
		return ret;
	}

	function closeWindow(panel) {
		if (panel) {
			panel.hide();
			panel.destroy();
		}
	}

	var zIndex = 300;	// Just keep counting up on the zindex so that new dialogs appear above the old ones.

	function create(params) {
		var header = params.header;
		var body = params.body;
		var width = params.width;
		var ok = params.ok;
		var cancel = params.cancel;
		var actionParams = params.params;
		var id = params.id;
		zIndex++;

		var panel = new Y.Panel({
			width: width,
			centered:true,
			visible: false,
			zIndex: zIndex,
			modal:true,
			headerContent: header,
			bodyContent: body,
			id: id,

			buttons: [
				{
					value: ok.text,
					action: function(e) {
						e.preventDefault();
						ok.action(panel, actionParams);
					},
					section: Y.WidgetStdMod.FOOTER
				},
				{
					value: cancel,
					action: function(e) {
						e.preventDefault();
						closeWindow(panel);
					},
					section: Y.WidgetStdMod.FOOTER
				}
			]
		});
		panel.render();
		panel.show();
		panel.setDataOnForm = setDataOnForm;

		return panel;
	}

	function displayMessage(id, type, msg) {
		var elError = Y.one('#' + id + ' .error');
		var elNotice = Y.one('#' + id + ' .notice');
		if (type === 'error') {
			elError._node.innerHTML = msg;
			elNotice._node.innerHTML = '';
		} else {
			elNotice._node.innerHTML = msg;
			elError._node.innerHTML = '';
		}
	}

	function errorDlg(message) {
		create({ header: "Error",
				body: message,
				width: 400,
				ok: { text: "Ok", action: closeWindow },
				cancel: "Cancel"
			});
	}

	function onSuccess(id, o, args) {
		var div = args[1].div;
		if (div)
			div = Y.one("#" + div);
		if (div)
			div._node.innerHTML = o.responseText;
		else
			errorDlg("Can't find the target div: " + args[1].div);
		closeWindow(args[0]);
	}

	function onFailure(id, o, args) {
		errorDlg("Failure: " + o.status + " " + o.responseText);
	}

	function getData(formId) {
		var data = getAuthenticityToken();
		var form = Y.one("#" + formId);
		if (form) {
			var els = form.all('input');
			els.each(function(el) {
				el = el._node;
				if (el.type === 'checkbox') {
					data[el.name] = el.checked;
				} else if (el.type === 'radio') {
					if (el.checked)
						data[el.name] = el.value;
				} else if (el.type !== 'button') {
					data[el.name] = el.value;
					data[el.name] = data[el.name].trim();
				}
			});
			els = form.all('textarea');
			els.each(function(el) {
				el = el._node;
				data[el.name] = el.value;
			});
			els = form.all('select');
			els.each(function(el) {
				el = el._node;
				var sel = el.selectedIndex;
				data[el.name] = el.options[sel].value;
			});
		}
		return data;
	}

	function okAction(panel, params) {
		if (params.url) {
			if (params.div || params.successCallback) {
				var ioParams = { on: { success: onSuccess, failure: onFailure }, arguments: [ panel, params ] };
				if (params.successCallback) {
					var callback = function() {
						eval(params.successCallback);
					}
					ioParams.on.success = callback;
				}
				if (params.method) ioParams.method = params.method;
				if (params.method && params.method != 'GET')
					ioParams.data = params.data;
				if (panel && params.type && params.progressMsg)
					displayMessage(params.type, 'notice', params.progressMsg);
				Y.io(params.url, ioParams);
			} else
				closeWindow(panel);
		} else
			closeWindow(panel);
	}

	function submit(panel, params) {
		params.data = getData(params.type + 'Form');
		mergeHashes(params.data, params.hidden, true);

		// First do client side validation before submitting the data.
		if (params.validate) {
			var msg = params.validate(params.data);
			if (msg) {
				displayMessage(params.type, 'error', msg);
				return;
			}
		}

		// Now see if we need confirm before submitting.
		if (params.confirm) {
			create({ header: params.confirmTitle,
				body: params.confirm,
				width: 400,
				ok: { text: params.yes, action: okAction },
				cancel: params.no,
				params: params
			});
		} else {
			okAction(panel, params);
		}
	}

	function name2Id(name) {
		return name.replace(/\[/g, '_').replace(/\]/g, '');
	}

	function makeId(name) {
		return " id='" + name2Id(name) + "'";
	}

	function nameAndId(name) {
		return makeId(name) + " name='" + name + "'";
	}

	function elAndClass(el, klass) {
		var html = "<" + el;
		if (klass)
			html += " class='" + klass + "'";
		return html;
	}

	function clearImage(node) {
		var el = Y.one("#"+node);
		el._node.src = "";
	}

	function drawElement(item, params) {
		var html = "";
		if (item.text) {
			html += elAndClass('scan', item.klass);
			html += '>' + item.text + "</scan>";
		} else if (item.input) {
			html += elAndClass('input', item.klass);
			html += nameAndId(item.input);
			html += " type='text' />";
		} else if (item.readonly) {
			html += elAndClass('input', item.klass);
			html += nameAndId(item.readonly);
			html += " readonly='readonly' type='text' />";
		} else if (item.select) {
			html += elAndClass('select', item.klass);
			html += nameAndId(item.select) + '>';
			for (var i = 0; i < item.options.length; i++) {
				html += "<option value='" + item.options[i].value + "'>" + item.options[i].text + "</option>";
			}
			html += "</select>";
		} else if (item.checkbox) {
			html += elAndClass('input', item.klass);
			html += nameAndId(item.checkbox);
			html += " type='checkbox' />";
		} else if (item.textarea) {
			html += elAndClass('textarea', item.klass);
			html += nameAndId(item.textarea);
			html += "></textarea>";
		} else if (item.image) {
			html += elAndClass('div', item.klass) + "><img src='' alt='" + item.alt + "'";
			html += makeId(item.image) + "/>";
			var url = params.url;
			if (url.indexOf('?')>0) url += '&'; else url += '?';
			html += "<a href='#' class='file_upload' data-upload-url='" + url + "file=upload' data-dlg-method='" + params.method + "' data-upload-id='" + item.image + "'>Upload Image</a>";
			if (item.removeButton)
				html += "<br /><a href='#' class='dialog' data-dlg-url='" + url + "file=remove' data-dlg-method='" + params.method + "' data-success-callback='clearImage(\"" + name2Id(item.image) + "\")'>" + item.removeButton + "</a>";
		} else {
			html += "<span>Unsupported: " + item + "</span>"
		}
		return html;
	}

	function constructDlg(dlgDescription, params) {
		var body = "<div class='error'></div><div class='notice'></div><form id='" + params.type + "Form'>";
		for (var i = 0; i < dlgDescription.rows.length; i++) {
			body += "<div class='row'>";
			for (var j = 0; j < dlgDescription.rows[i].length; j++) {
				body += drawElement(dlgDescription.rows[i][j], params);
			}
			body += "</div>";
		}
		body += "</form>";
		mergeHashes(params, dlgDescription, true);
		var panel = create({ header: dlgDescription.title, body: body, id: params.type,
			width: dlgDescription.width, ok: { text: "Submit", action: submit }, cancel: "Cancel",
			params: params });
		if (dlgDescription.focus) {
			var el = Y.one("#" + dlgDescription.focus);
			if (el)
				el._node.focus();
		}

		// Klunky way of setting the class: I didn't see a way to do it directly when creating the panel.
		if (params.klass) {
			var outer = Y.one("#"+params.type);
			outer.addClass(params.klass);
		}
		return panel;
	}

	function getDataSuccess(id, o, args) {
		var dlg = args[0];
		var dlgDescription = args[1];
		var params = args[2];
		var data;
		try {
			data = Y.JSON.parse(o.responseText);
		}
		catch (e) {
			var message = "Error in retrieving the data from the server<br />URL: " + params.ajaxUrl;
			dlg.set('bodyContent', message);
			return;
		}
		closeWindow(dlg);
        // TODO: Add in rows here if needed!!
        if (!dlgDescription.carousels_added) {
            var carousel_row = -1;
            dlgDescription.rows.forEach(
                    function(element, index) {
                        if (element[0].display_carousels) {
                            carousel_row = index;
                        }
                    })
            if (carousel_row >= 0 && data.all_carousels) {

                var dlgTopRows = dlgDescription.rows.splice(0,carousel_row+1);
                var dlgBottomRows = dlgDescription.rows;
                data.all_carousels.forEach(
                    function(element, index) {
                        dlgTopRows.push([{ text: element.name, klass: 'left-indented' },
                                         { checkbox: 'archive[carousel_list['+element.id+']]', klass: 'right-narrow' }]);
                    }
                )
                dlgDescription.rows = dlgTopRows.concat(dlgBottomRows);
                dlgDescription.carousels_added = true;
            }
        }
		var panel = constructDlg(dlgDescription, params);
		if (dlgDescription.populate)
			dlgDescription.populate(panel, data);
	}

	function getDataFailure(id, o, args) {
		var dlg = args[0];
		var dlgDescription = args[1];
		var params = args[2];
		var message = "Error #" + o.status + " " + o.statusText + "<br />URL: " + params.ajaxUrl;
		dlg.set('bodyContent', message);
	}

	function display(params) {
		var dlgDescription = dlgTypes[params.type];
		if (!dlgDescription) {
			errorDlg("Can't find the dialog type \"" + params.type + "\". Did you register it?" );
			return;
		}
		if (!dlgDescription.width) dlgDescription.width = 400;

		if (params.ajaxUrl) {
			var dlg = create({ header: dlgDescription.title,
					body: "Retrieving Data... Please wait.",
					width: dlgDescription.width,
					ok: { text: "Ok", action: closeWindow },
					cancel: "Cancel"
				});
			var ioParams = { on: { success: getDataSuccess, failure: getDataFailure }, arguments: [ dlg, dlgDescription, params ] };
			if (params.ajaxData) {
				var arr = params.ajaxData.split(';');
				ioParams.data = {};
				for (var i = 0; i < arr.length; i++) {
					var arr2 = arr[i].split(':');
					if (arr2.length === 2)
						ioParams.data[arr2[0]] = arr2[1];
				}
			}
			Y.io(params.ajaxUrl, ioParams);
		} else
			constructDlg(dlgDescription, params);
	}

	function doDialog(params) {
		if (params.type)
			display(params);
		else
			submit(null, params);
	}

	function doFileUploadDialog(params) {
		var doUpload = function(panel) {
			// Define a function to handle the start of a transaction
			function start(id, args) {
				displayMessage('gd_upload_dlg', 'error', '');
			}

			// Define a function to handle the response data.
			function complete(id, o, args) {
				var data = o.responseText; // Response data.
				var arr = data.split(';');
				if (arr[0] === 'OK') {
					var imgId = "#" + name2Id(params.id);
					var el = Y.one(imgId);
					el._node.src = arr[1];
					closeWindow(panel);
				} else {
					if (arr.length > 1)
						displayMessage('gd_upload_dlg', 'error', arr[1]);
					else
						displayMessage('gd_upload_dlg', 'error', "We're sorry. You hit an error! Please try again or contact technical support. (" + arr[0] + ")");
				}
			}

			// Start the transaction.
			var request = Y.io(params.url, { method: 'POST', form: { id: 'gd_upload_form', upload: true },
				on: { start: start, complete: complete }});
		};

		var body = "<div class='error'></div><div class='notice'></div>";
		body += "<form id='gd_upload_form'>";
		body += "<input id='_" + makeId(params.id) + "' type='file' name='" + params.id + "' size='35'></div>";
		var auth = getAuthenticityToken();
		if (params.method)
			body += "<input id='_method' type='hidden' name='_method' value=" + params.method + ">";
		body += "<input id='authenticity_token' type='hidden' name='authenticity_token' value='" + auth.authenticity_token + "'>";
		body += "</form>";

		var dlg = create({ header: "Upload File",
			id: 'gd_upload_dlg',
			body: body,
			width: 400,
			ok: { text: "Ok", action: doUpload },
			cancel: "Cancel"
		});
	}

	Y.delegate("click", function(e) {
		var data = { url: e.target.getAttribute("data-dlg-url"),
			method: e.target.getAttribute("data-dlg-method"),
			confirm: e.target.getAttribute("data-dlg-confirm"),
			confirmTitle: e.target.getAttribute("data-dlg-confirm-title"),
			yes: e.target.getAttribute("data-dlg-confirm-yes"),
			no: e.target.getAttribute("data-dlg-confirm-no"),
			type: e.target.getAttribute("data-dlg-type"),
			ajaxUrl: e.target.getAttribute("data-ajax-url"),
			div: e.target.getAttribute("data-parent-div"),
			ajaxData: e.target.getAttribute("data-ajax-data"),
			successCallback:  e.target.getAttribute("data-success-callback")
		};
		if (!data.confirmTitle) data.confirmTitle = "Are you sure?";
		if (!data.yes) data.yes = "Yes";
		if (!data.no) data.no = "No";

		e.halt();
		doDialog(data);
	}, 'body', ".dialog");

	Y.delegate("click", function(e) {
		var data = { url: e.target.getAttribute("data-upload-url"),
			method: e.target.getAttribute("data-dlg-method"),
			id: e.target.getAttribute("data-upload-id")
		};

		e.halt();
		doFileUploadDialog(data);
	}, 'body', ".file_upload");
});
