module IconsHelper
  def missing_icon
    image_tag('icon-star1.gif', :style => 'vertical-align: middle')
  end

  def icon(image)
    image_tag(image, :style => 'vertical-align: middle')
  end

  def icon_arrow_up
    image_tag('icon_arrow_up.png', :size => '11x11')
  end

  def icon_arrow_down
    image_tag('icon_arrow_down.png', :size => '11x11')
  end
end