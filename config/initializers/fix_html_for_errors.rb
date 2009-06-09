# This hack prevents form helpers from puttin a fieldWithErrors DIV around
# field with errors. That introduced breaks if the field happened to have
# something to its right as a help icon.
ActionView::Base.field_error_proc = lambda {|html_tag, instance| html_tag}
