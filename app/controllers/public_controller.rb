#
# The actions in this controller are coupled with the content of public/ror.xml.
#
# TODO: Refactor Public and Account Controllers to share filters and skips.
class PublicController < ApplicationController
  before_filter :register_referer_and_landing_page

  skip_before_filter :find_account
  skip_before_filter :login_required
  skip_before_filter :compute_totals_for_sidebar

  def login
    if request.post?
      User.all(:conditions => {:email => params[:email]}).each do |u|
        if User.authenticate(u.account, params[:email], params[:password])
          logger.info("public login from user #{u.email} with id #{u.id}")
          u.account.enable_direct_login!(u)
          redirect_to account_home_page_url(u.account)
          return
        end
      end
      flash.now[:notice] = "Por favor revise los datos de acceso."
    end
  end

  def accounts_reminder
    users = User.find_all_by_email(params[:email])
    unless users.empty?
      urls = users.map {|u| account_home_page_url(u.account)}
      Mailer.deliver_accounts_reminder(params[:email], urls)
    end
    # We interporlate the email here because the view calls h().
    flash[:reminder_sent] = "yes"
    flash[:reminder_email] = params[:email]
    redirect_to :action => 'login'
  end
  verify :only => :accounts_reminder, :method => :post, :redirect_to => {:action => 'index'}

  def tour
  end

  def terms_of_service
    render :layout => false
  end

  #To check Exception Notifier
  def error  
    raise RuntimeError, "Generating an error"  
  end 
  
  def store_campaign_code
    unless params[:campaign_code].blank?
      session[:campaign_code] = params[:campaign_code]
    end
  end
  private :store_campaign_code

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
