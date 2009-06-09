# This code is based on AWDwR 2nd edition, page 497.
module SelectBuilderHelper
  def with_selectors_form_for(name, *args, &block)
    wrap_with_select_builder(:form_for, name, *args, &block)
  end

  def with_selectors_fields_for(name, *args, &block)
    wrap_with_select_builder(:fields_for, name, *args, &block)
  end

  def with_selectors_remote_form_for(name, *args, &block)
    wrap_with_select_builder(:remote_form_for, name, *args, &block)
  end

  def wrap_with_select_builder(what, name, *args, &block)
    options = args.last.is_a?(Hash) ? args.pop : {} 
    options = options.merge(:builder => SelectBuilder) 
    args = (args << options) 
    send(what, name, *args, &block)    
  end
end