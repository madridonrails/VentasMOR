module VentasgemUtils
  def self.normalize(str)
    return '' if str.nil?
    n = str.chars.downcase.strip.to_s
    n.gsub!(/[àáâãäåāă]/,    'a')
    n.gsub!(/æ/,            'ae')
    n.gsub!(/[ďđ]/,          'd')
    n.gsub!(/[çćčĉċ]/,       'c')
    n.gsub!(/[èéêëēęěĕė]/,   'e')
    n.gsub!(/ƒ/,             'f')
    n.gsub!(/[ĝğġģ]/,        'g')
    n.gsub!(/[ĥħ]/,          'h')
    n.gsub!(/[ììíîïīĩĭ]/,    'i')
    n.gsub!(/[įıĳĵ]/,        'j')
    n.gsub!(/[ķĸ]/,          'k')
    n.gsub!(/[łľĺļŀ]/,       'l')
    n.gsub!(/[ñńňņŉŋ]/,      'n')
    n.gsub!(/[òóôõöøōőŏŏ]/,  'o')
    n.gsub!(/œ/,            'oe')
    n.gsub!(/ą/,             'q')
    n.gsub!(/[ŕřŗ]/,         'r')
    n.gsub!(/[śšşŝș]/,       's')
    n.gsub!(/[ťţŧț]/,        't')
    n.gsub!(/[ùúûüūůűŭũų]/,  'u')
    n.gsub!(/ŵ/,             'w')
    n.gsub!(/[ýÿŷ]/,         'y')
    n.gsub!(/[žżź]/,         'z')
    n.gsub!(/\s+/,           ' ')
    n.delete!('^ a-z0-9_/\\-.')
    n
  end

  def self.normalize_for_db(str)
    normalize(str)
  end

  def self.normalize_for_url(str)
    # normalize and convert whitespace, slashes, and dots to hyphens
    normalize(str).tr('^a-z0-9_', '-')
  end

  def self.sanitize_filename(string)
    # normalize and remove whitespace and slashes
    normalize(string).delete('^a-z0-9_.')
  end

  def self.parse_integer(i)
    parse_decimal(i).to_i
  end

  # Returns a BigDecimal out of the string n, 0.0.to_d on failure.
  def self.parse_decimal(n)
    return 0.0.to_d if n.blank?

    n = n.dup

    # remove everything that cannot be part of a number, as currency symbols or garbage
    n.gsub!(/[^.,\d]+$/, '')

    ndots = n.count('.')
    ncommas = n.count(',')
    return n.to_d if ndots.zero? && ncommas.zero?

    # if it has a single separator and it is repeated assume it is a thousands separator
    if (ndots.zero? && ncommas > 1) || (ndots > 1 && ncommas.zero?)
      n.tr!('.,', '')
      return n.to_d
    end

    # if n has no comma and at most one dot delegate and return
    return n.to_d if ncommas.zero?

    # if it has a comma, but no dot, assume it is a decimal separator
    return n.sub(',', '.').to_d if ndots.zero?

    # if we get here it has both a comma and a dot, strip whitespace
    n = n.strip

    # take sign and delete it, if any
    s = n.first == "-" ? -1 : 1
    n.sub!(/^[-+]/, '')

    # extract and remove the decimal part, which is assumed to be the one
    # after the rightmost separator, no matter whether it is a comma or a dot
    n.sub!(/[.,](\d*)$/, '')
    decimal_part = $1 # perhaps the empty string, no problem

    # in what remains, which is taken as the integer part, any non-digit is
    # simply ignored
    n.gsub!(/\D/, '')

    # done
    return s*("#{n}.#{decimal_part}".to_d)
  end

  def self.integer?(n)
    n = VentasgemUtils.parse_decimal(n) if n.is_a?(String)
    return n == n.to_i
  end

  # This method understands dd/mm/yyyy. Returns nil on failure.
  def self.parse_date(str)
    day, month, year = str.split("/")
    begin
      return Date.new(year.to_i, month.to_i, day.to_i)
    rescue
      return nil
    end
  end

  COLORS = []
  COMPONENTS = [50, 130, 210].map {|n| "%02X" % n}
  COMPONENTS.each do |r|
    COMPONENTS.each do |g|
      COMPONENTS.each do |b|
        COLORS << '#' + r + g + b unless r == g && g == b
      end
    end
  end

  def self.random_color(taken_colors)
    selectable_colors = COLORS - taken_colors
    # If there are more than 24 salesmen we just don't care, just assign something.
    # We expect all accounts to have, say, less than 20 salesmen.
    selectable_colors = COLORS if selectable_colors.empty?
    selectable_colors[rand(selectable_colors.length)]
  end

  # Inspired by the random token generator of FACTURAgem.
  @@token_chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + ['_']
  def self.random_password
    token = ''
    8.times { token << @@token_chars[rand(@@token_chars.length)] }
    token
  end
end