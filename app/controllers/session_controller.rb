# This controller handles the login/logout function of the site.
class SessionController < ApplicationController
  layout "session"
  skip_before_filter :login_required, :except => :destroy
  skip_before_filter :compute_totals_for_sidebar

  def new
    render :layout => 'public'
  end

  def create
    if self.current_user = User.authenticate(@current_account, params[:email], params[:password])
      logger.info("user with email #{params[:email]} was successfully authenticated")
      redirect_back_or_default root_url
    else
      logger.info("user with email #{params[:email]} failed authentication")
      flash[:error] = "Por favor revise los datos de acceso."
      render :action => 'new',:layout => 'public'
    end
  end

  def destroy
    reset_session
    redirect_to root_url
  end

  def lost_password
    if request.post?
      flash[:random_password_sent] = "yes" # give no clue to the user about the success or failure
      flash[:random_password_email] = params[:email]
      if user = @current_account.users.find_by_email(params[:email])
        user.chpass
        Mailer.deliver_random_password(user, user.password)
      end
      redirect_to new_session_path
    end
  end

  def chpass
    @chpass_token = params[:chpass_token]
    if @chpass_token.blank? || @current_account.chpass_token.nil? || @current_account.chpass_token.token != @chpass_token
      logger.warn("invalid chpass request")
      redirect_to :action => 'login'
      return
    end
    @user = @current_account.owner
    if request.post?
      @user.password              = params[:password]
      @user.password_confirmation = params[:password_confirmation]
      if @user.validate_attributes_and_save(:only => [:password, :password_confirmation])
        # chpass tokens are one shot for security reasons
        if not @current_account.chpass_token.destroy
          # Race conditions are very unlikely here, I think the only possible way to enter
          # here is that the database has a problem, we cannot do too much in that case.
          logger.error("I couldn't destroy the chpass token '#{@chpass_token}' of #{@current_account}")
        end
        # log the user in automatically
        self.current_user = User.authenticate(@current_account, @user.email, @user.password)
        redirect_to "/"
        return
      end
    end
    render :action => 'chpass', :layout => 'public'
  end  
end
