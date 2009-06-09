function add_underlines() {
    var fine_border_bottom = function (input) {
        if (!input.hasClassName('home-form-field'))
          input.addClassName("underline");
    };
    $$('input[type="text"]').each(fine_border_bottom);
    $$('input[type="password"]').each(fine_border_bottom);
}
document.observe('dom:loaded', add_underlines);

function style_editable_cells() {
    $$('td.editable').each(function (cell) {
        bg = cell.style.background;
        cell.onmouseover = function () { cell.style.background = "#eee";};
        cell.onmouseout  = function () { cell.style.background = bg};
    });
}
document.observe('dom:loaded', style_editable_cells);

/*
  We turn autocompletion off in all text fields so that numbers,
  dates, invoice numbers, etc. do not interfere. This gives a clean
  data entry experience. Nevertheless, some text fields do want to
  have autocompletion on, and in that case they say so adding a class
  "autocomplete".

  We do not use the "autocomplete" attribute in source code because
  it is not in the standard and gives warnings in HTML validators.
*/
function turn_autocomplete_off() {
    $$('input[type="text"]').each(function (e) {
        if (!e.hasClassName('autocomplete'))
            e.setAttribute("autocomplete", "off");
    });
}
document.observe('dom:loaded', turn_autocomplete_off);

function set_default_maxlength() {
    var set_maxlength = function (input) {
        if (input.maxLength == -1)
            input.maxLength = 255;        
    }
    $$('input[type="text"]').each(set_maxlength);
    $$('input[type="password"]').each(set_maxlength);
}
document.observe('dom:loaded', set_default_maxlength);

function focus_first_element_of_first_form() {
    var fs = document.forms;
    for (var i = 0; i < fs.length; ++i) {
        var f = $(fs[i]);
        if (!f.hasClassName('nofocus')) {
            f.focusFirstElement();
            break;
        }
    }
}
document.observe('dom:loaded', focus_first_element_of_first_form);

/*
  If the users cancels creation errors shouldn't be there if he
  decides to pop up the form again later.
*/
function clean_errors_in_customer_redbox() {
    var re = /^errors_for_customer_/;
    $$('span.error').each(function (span) {
       if (span.id && re.test(span.id))
         span.update('');
    });
}

/*
  If the users cancels creation errors shouldn't be there if he
  decides to pop up the form again later.
*/
function clean_errors_in_salesman_redbox() {
    var re = /^errors_for_salesman_/;
    $$('span.error').each(function (span) {
       if (span.id && re.test(span.id))
         span.update('');
    });
}

function check_acceptance_of_terms_of_service(f) {
    if (f.accept_terms_of_service.checked) return true;
    alert("Para completar el registro debe aceptar las condiciones del servicio.");
    return false;
}

/* Dynamically adjusts the size of a text-field to more or less fit its content, minimum size 3. */
function autofit(input) {
    input.size = Math.max(input.value.length+2, 5);
}

function check_availability_of_short_name(input) {
    new Ajax.Request('/accounts/available', {asynchronous:true, evalScripts:true, method:'get', parameters:"short_name=" + input.value});
}

function hide_combos_for_redbox_if_ie(root_id) {
    var root = $(root_id);
    if (Prototype.Browser.IE) {
        var selects = root.getElementsByTagName('select');
        for (var i = 0; i < selects.length; i++) {
            $(selects[i]).hide();
        }
    }
}

function show_combos_for_redbox_if_ie(root_id) {
    var root = $(root_id);
    if (Prototype.Browser.IE) {
        var selects = root.getElementsByTagName('select');
        for (var i = 0; i < selects.length; i++) {
            $(selects[i]).show();
        }
    }
}

function toggle_password_field(field_id) {
    var field = $(field_id);
    var current_type = field.readAttribute('type');
    var new_type = (current_type == 'password' ? 'text' : 'password');
    var new_input = new Element(
        'input', {
            'type':  new_type,
            'id':    field_id,
            'name':  field.getAttribute('name'),
            'value': $F(field),
            'class': field.readAttribute('class'),
            'size':  field.readAttribute('size')
    });
    field.parentNode.replaceChild(new_input, field);
}
