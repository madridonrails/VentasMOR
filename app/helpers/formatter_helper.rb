module FormatterHelper
  def format_date_short(date)
    date.strftime("%d/%m/%Y") rescue ''
  end
  alias :format_date :format_date_short

  def format_amount(amount, options={})
    options = {
      :format_zero_as_empty_string => false,
      :force_integer => false
    }.merge(options)
    return '' if amount.nil?
    return '' if amount.zero? and options[:format_zero_as_empty_string]
    if amount.to_i == amount || options[:force_integer]
      number_with_delimiter(amount.to_i, '.')
    else
      number_with_delimiter("%0.2f" % amount, '.', ',')
    end
  end

  def format_boolean(b)
    b ? "Sí" : "No"
  end
end