module ApplicationHelper
  def colgroup_for_data_tables
    return <<-COLGROUP
    <colgroup>
      <col width="20%" />
      <col width="80%" />
    </colgroup>
    COLGROUP
  end

  def date_picker(relative_to, fire_onchange=false)
    options = [
      "relative: '#{relative_to}'", # text field associated to this date picker
      "language: 'sp'",             # UI language is Spanish
      "disableFutureDate: false",   # dates in the future are allowed
      "keepFieldEmpty: true"        # do not let the user manually edit the field
    ]
    options << "afterClose: function () { $('#{relative_to}').onchange() }" if fire_onchange
    return <<-HTML
    <script type="text/javascript" charset="utf-8">
      new DatePicker({#{options.join(", ")}});
    </script>
    HTML
  end

  def x_simple_format(str)
    simple_format(h(str)).sub(%r{\A<p>}i, '').sub(%r{</p>\z}i, '')
  end

  # If the object has validation errors on method, returns the list of messages.
  # We prepend a BR to each error message and the list is wrapped in a SPAN with
  # class "error" and id "errors_for_object_method". If there's no error message
  # the SPAN is still returned so that it is available to Ajax forms.
  #
  # This helper is thought for displaying error messages below their
  # corresponding fields.
  def errors_for_attr(object, method, generate_span_id=true)
    target = object.is_a?(ActiveRecord::Base) ? object : instance_variable_get("@#{object}")
    
    errors_list = ''
    if errors = target.send(:errors).on(method)
      errors = [errors] if errors.is_a?(String)
      errors_list = %Q{<br/>#{errors.join("<br/>")}}
    end

    span_id = ''
    if generate_span_id
      label = target.class.to_s.underscore
      span_id = %Q( id="errors_for_#{label}_#{method}")
    end

    return %Q(<span#{span_id} class="error">#{errors_list}</span>)
  end

  # Auxiliary helper to have a link in the view that shows a message in a
  # JavaScript dialog.
  def not_yet_implemented(name, msg="Not Yet Implemented", options={})
    '<i>' + link_to_function(name, "alert('#{escape_javascript(msg)}')", options) + '</i>'
  end

  def boolean_as_check_box(value)
    value ? image_tag("check_box_checked.png") : image_tag("check_box_unchecked.png")
  end

  # IDs in HTML cannot start with a number, that's why we put a prefix.
  def random_id
    "random" + Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
  end

  def hide_if(condition)
    ' style="display:none"' if condition
  end

  def options_for_tooltips
    %q(BGCOLOR, '#ab9b7d', FONTCOLOR, '#fff', BORDERWIDTH, 0)
  end
end
