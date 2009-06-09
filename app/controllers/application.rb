class ApplicationController < ActionController::Base
  helper :all

  include ExceptionNotifiable
  include AuthenticatedSystem
  include AccountLocation

  before_filter :trace_user_agent
  before_filter :set_controller_and_action_names
  before_filter :ensure_the_url_has_a_subdomain
  before_filter :find_account
  before_filter :login_required
  before_filter :compute_totals_for_sidebar

  filter_parameter_logging :password

# None of these methods are callable as actions.
protected

  # Returns whether <tt>@current_user</tt> has admin role.
  #
  # This method assumes <tt>@current_user</tt> is set. It does not have a recue
  # fallback or anything like that returning false because calling this method
  # without a user logged in is a bug and has to be apparent.
  def admin?
    @current_user.administrator?
  end
  helper_method :admin?

  # Robust computation of +order_by+ for column ordering in tables. This method
  # checks +params+ for a <tt>:order_by</tt> key.
  def order_by(ncols, default=0)
    if params[:order_by].blank?
      order_by = default
    else
      begin
        order_by = params[:order_by].to_i
        unless 0 <= order_by && order_by < ncols
          order_by = default
        end
      rescue Exception => e
        logger.error(e)
        order_by = default
      end
    end
    order_by
  end

  # Robust computation of +direction+ for column ordering in tables. This method
  # checks +params+ for a <tt>:direction</tt> key.
  def direction(default='ASC')
    direction = params[:direction]
    direction = default if direction.blank?
    direction = default unless ['ASC', 'DESC'].include?(direction)
    direction
  end

  # Returns the URL of the public home page, computing domain and port
  # dynamically.
  def public_home_page_url(append_request_uri=false)
    url = "http://www.#{account_domain}"
    url << (append_request_uri ? request.request_uri : '/')
    url
  end
  helper_method :public_home_page_url

  # Returns the URL of the home page of +account+.
  def account_home_page_url(account)
    "http://#{account.short_name}.#{account_domain}"
  end
  helper_method :account_home_page_url

  # Declarative way to ensure an action responds only to Ajax calls.
  #
  #   def amount
  #     # update some amount somewhere
  #   end
  #   xhr_only :amount
  #
  # This declaration is just a marker, that's why we do not take any special
  # action but rendering nothing.
  def self.xhr_only(action_name)
    verify :xhr => true, :only => action_name, :render => {:nothing => true}
  end

  # The name of the current controller and actions is always available using
  # <tt>@current_(controller|action)</tt>.
  def set_controller_and_action_names
    @current_controller = controller_name
    @current_action     = action_name
  end

  # We need this redirection not only for users, I founded that some bots
  # request public pages to ventasgem domain directly. We need to respond with the
  # appropiate redirection so they don't index the error page. They would
  # because the error page is a successful HTTP response.
  def ensure_the_url_has_a_subdomain
    if account_subdomain.blank?
      redirect_to public_home_page_url(true), :status => :moved_permanently
    end
  end

  # All actions except the ones that deal with the public pages and login form
  # need to know the account in scope.
  def find_account
    @current_account = Account.find_by_short_name(account_subdomain)
    if !@current_account
      logger.info("There's no account with short name #{account_subdomain}, redirecting to the home")
      redirect_to public_home_page_url
    elsif @current_account.blocked?
      logger.info("Access attempt by blocked account #{account_subdomain}, redirecting to the home")
      redirect_to public_home_page_url
    else
      logger.info("Request for account #{@current_account.short_name}")
      handle_direct_login if @current_account.direct_login?
    end
  end

  def handle_direct_login
    if u = @current_account.users.find_by_email(@current_account.direct_login)
      logger.info("Direct login of user #{u.name} with email #{u.email} and ID = #{u.id} into account #{@current_account.short_name}")
      self.current_user = u
    else
      logger.warn("Failed direct login of email #{@current_account.direct_login} into account #{@current_account.short_name}")
      redirect_to account_home_page_url(@current_account)
    end
    # In any case clear the flag.
    @current_account.disable_direct_login!
  end

  def compute_totals_for_sidebar
    @total_pipeline, @weighted_total_pipeline = admin? ? @current_account.totals_pipeline : @current_user.totals_pipeline
  end

  # see http://www.iopus.com/imacros/demo/v6/user-agent.htm
  def request_from_a_mac?
    request.env['HTTP_USER_AGENT'].downcase.index('macintosh')
  end

  # see http://www.iopus.com/imacros/demo/v6/user-agent.htm
  def request_from_windows?
    request.env['HTTP_USER_AGENT'].downcase.index('windows')
  end

  BOTS_REGEXP = %r{
    Baidu        |
    Gigabot      |
    Google       |
    libwww-perl  |
    lwp-trivial  |
    msnbot       |
    SiteUptime   |
    Slurp        |
    WordPress    |
    ZIBB         |
    ZyBorg       |
    Yahoo        |
    Lycos_Spider |
    Infoseek     |
    ia_archiver  |
    scoutjet
  }xi
  def trace_user_agent
    if request.user_agent =~ BOTS_REGEXP
      logger.info("(BOT) #{request.user_agent}")
    else
      logger.info("(BROWSER) #{request.user_agent}")
    end
  end
end
