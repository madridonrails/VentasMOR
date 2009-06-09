module LinksHelper
  def logo_linked_to_public_home_page
    link_to(image_tag('logo.png'), public_home_page_url)
  end

  def link_to_user(user)
    link_to h(user.name), user
  end

  def link_to_customer(customer)
    link_to h(customer.name), customer
  end

  def link_to_offer(offer)
    link_to h(offer.name), offer
  end

  def link_to_status(status)
    path = case status
      when CustomStatus; status
      when LostStatus; lost_status_path
      when WonStatus; won_status_path
    end
    link_to h(status.name), path
  end
end