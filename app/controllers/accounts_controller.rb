# TODO: Refactor common stuff with PublicController to a common ancestor.
class AccountsController < ApplicationController
  layout 'public'

  before_filter :register_referer_and_landing_page

  skip_before_filter :find_account
  skip_before_filter :login_required
  skip_before_filter :compute_totals_for_sidebar

  def new
    @account = Account.new
    @user    = @account.users.build
  end

  def create
    @account = Account.new(params[:account])
    @account.referer       = session[:referer]
    @account.landing_page  = session[:landing_page]
    @account.campaign_code = session[:campaign_code] unless session[:campaign_code].blank?

    @user = @account.users.build(params[:user])
    @user.administrator = true
    @user.salesman      = true  

    if @account.save
      clean_tracking_stuff_from_session
      @account.enable_direct_login!(@user)
      Mailer.deliver_welcome(@account, account_home_page_url(@account))
      redirect_to account_home_page_url(@account)
    else
      render :action => 'new'
    end
  end

  # This resource represents whether the short name passed as argument is
  # available. This is called via Ajax from the signup form.
  def available
    sn = VentasgemUtils.normalize_for_url(params[:short_name])
    available = '<em style="color: #0FC10B">(disponible)<em>'
    if sn.blank? || Account.find_by_short_name(sn) || Config.reserved_subdomains.include?(sn)
      available = '<span class="error">(no disponible)</span>'
    elsif sn != params[:short_name]
      available = %Q{<em style="color: #0FC10B">(disponible como "#{sn}")<em>}
    end
    render :update do |page|
      page.replace_html 'available', available
    end
  end
  xhr_only :available

  # Here we clean tracking stuff in case someone comes back and performs a
  # signup again.
  def clean_tracking_stuff_from_session
    [:campaign_code, :referer, :landing_page].each do |k|
      session[k] = nil
    end
  end
  private :clean_tracking_stuff_from_session

  # Stores the referer and landing page to register them if there's a signup.
  def register_referer_and_landing_page
    return unless session[:referer].blank? && session[:landing_page].blank?
    session[:referer]      ||= request.referer
    session[:landing_page] ||= request.url
    origin = session[:referer].blank? ? 'as a direct access (no referer header)' : "coming from #{session[:referer]}"
    logger.info("new visit #{origin}")
  end
  private :register_referer_and_landing_page
end
