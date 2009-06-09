module ListingsHelper
    def table_header(options)
    options = {
      :current_order_by  => @current_order_by,
      :current_direction => @current_direction
    }.merge(options)
    path = params.slice(:search)

    # The empty :url hash fills the URL with the current controller and action.
    # If we come from a nested offer we always end at OffersController#index,
    # so we loose the scope. That's why we need to add it here. This is dirty and
    # shameless I must recognize, but I didn't found a way to cleanly generate a
    # link to self so to speak.
    path[@scope_key] = @scope_value if @scope_key

    html = '<tr>'
    index = 0
    options[:labels].each do |label, non_orderable|
      html << '<th nowrap="nowrap">'
      if non_orderable
        html << label
      else
        path[:order_by] = index
        if index == options[:current_order_by]
          icon = '&nbsp;' + (options[:current_direction] == 'ASC' ?  icon_arrow_up : icon_arrow_down)
          path[:direction] = (options[:current_direction] == 'ASC' ? 'DESC' : 'ASC')
        else
          icon = ''
          path[:direction] = 'ASC'
        end
        html << link_to("#{label}#{icon}", path)
      end
      html << '</th>'
      index += 1
    end
    html << '</tr>'
    html
  end

  def theres_pagination(collection)
    collection.total_pages > 1
  end
end