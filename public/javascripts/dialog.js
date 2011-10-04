// This wraps the modal dialog ability so that a dialog can be called with just a properly marked up <a>
//
//data-url
//data-method
//data-confirm
//data-confirm-title
//data-confirm-yes
//data-confirm-no
//data-dlg-type [must match one of the types registered in js]
//data-ajax-url
//data-parent-div
//data-ajax-data
//
//If data-dlg-type is defined, then that dialog is displayed.
//If the dialog wasn't specified, a dlg with an error message is displayed.
//If data-dlg-type is not defined, skip to confirm.
//If data-ajax-url is defined then a spinner is shown and the ajax call is made.
//If successful, then the dlg is populated.
//If not successful, then an error message is displayed.
//On submit,
//if data-confirm, the confirmation message is put up.
//if data-parent-div then it is an ajax call, otherwise it is a regular page change.
//
// data types are defined by registering the data type by firing the following event:
//function registerDialogType(name, json) {
//	YUI().use('node', function(Y) {
//		Y.Global.fire('dialog:registerDialogType', name, json);
//	});
//}
//
// "name" is the name that you use in data-dlg-type, and "json" is what defines the dialog.

/*global YUI */
YUI().use('node', "panel", "io-base", 'querystring-stringify-simple', 'json-parse', function(Y) {
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

	function create(params) {
		var header = params.header;
		var body = params.body;
		var width = params.width;
		var ok = params.ok;
		var cancel = params.cancel;
		var actionParams = params.params;
		var id = params.id;

		var panel = new Y.Panel({
			width: width,
			centered:true,
			visible: false,
			zIndex: 500,
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
			if (params.div) {
				var ioParams = { on: { success: onSuccess, failure: onFailure }, arguments: [ panel, params ] };
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

	function nameAndId(name) {
		return " id='" + name.replace(/\[/, '_').replace(/\]/, '') + "' name='" + name + "'";
	}

	function elAndClass(el, klass) {
		var html = "<" + el;
		if (klass)
			html += " class='" + klass + "'";
		return html;
	}

	function drawElement(item) {
		var html = "";
		if (item.text) {
			html += elAndClass('scan', item.klass);
			html += '>' + item.text + "</scan>";
		} else if (item.input) {
			html += elAndClass('input', item.klass);
			html += nameAndId(item.input);
			html += " type='text' />";
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
				body += drawElement(dlgDescription.rows[i][j]);
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
			if (params.ajaxData)
				ioParams.data = params.ajaxData;
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
			ajaxData: e.target.getAttribute("data-ajax-data")
		};
		if (!data.confirmTitle) data.confirmTitle = "Are you sure?";
		if (!data.yes) data.yes = "Yes";
		if (!data.no) data.no = "No";

		e.halt();
		doDialog(data);
	}, 'body', ".dialog");
});
