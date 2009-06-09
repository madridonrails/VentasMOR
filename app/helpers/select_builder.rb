class SelectBuilder < ActionView::Helpers::FormBuilder

  # We don't have h() here because this module is not included in ActionView::Base.
  def h(str)
    ERB::Util.html_escape(str)
  end

  def country_choices
    @@country_choices ||= Country.ordered.map {|c| [h(c.name), c.id]}
  end

  def country_selector(method = :country_id, options = {}, html_options = {})
    options[:selected] = Country.spain.id unless @object && @object.send(method)
    select method, country_choices, options, html_options
  end

  def customer_choices(account)
    account.customers_ordered.map {|c| [h(c.name), c.id]}
  end

  def customer_selector(account, method = :customer_id, options = {}, html_options = {})
    select method, customer_choices(account), options, html_options
  end

  def salesman_choices(account)
    account.salesmen_ordered.map {|s| [h(s.name), s.id]}
  end

  def salesman_selector(account, method = :salesman_id, options = {}, html_options = {})
    select method, salesman_choices(account), options, html_options
  end

  def status_choices(account)
    account.statuses_ordered.map {|c| [h(c.name), c.id]}
  end

  def status_selector(account, method = :status_id, options = {}, html_options = {})
    select method, status_choices(account), options, html_options
  end
end