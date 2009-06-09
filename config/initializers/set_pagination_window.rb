ActiveRecord::Base.class_eval do
  # This method is checked by will_paginate.
  def self.per_page
    Config.pagination_window
  end
end