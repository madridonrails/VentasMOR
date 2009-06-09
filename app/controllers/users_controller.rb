class UsersController < ApplicationController
  before_filter :find_user, :only => %w(edit update show destroy)
  before_filter :require_admin, :except => %w(show me edit update)
  before_filter :require_admin_or_me, :only => %w(show edit update)
  before_filter :protect_roles, :only => %w(create create_for_offer update)

  def index
    @current_order_by = order_by(3, 0)
    @current_direction = direction
    @users = @current_account.users.paginate(:page => params[:page], :order => [
      "name_normalized #@current_direction",
      "administrator #@current_direction",
      "salesman #@current_direction"
    ][@current_order_by])
  end

  def new
    @user = User.new
  end

  def create
    @user = @current_account.users.create(params[:user])
    if @user.save
      redirect_to @user
    else
      render :action => 'new'
    end
  end

  # This action is called from the redbox in the offer forms. It responds
  # only to POST via xhr.
  def create_for_offer
    @user = @current_account.users.build(params[:user])
    if @user.save
      # Create dummy objects to be able to rebuild the salesmen selector.
      @offer = @current_account.offers.build
      @offer.salesman = @user if @user.salesman?
    end
  end
  xhr_only :create_for_offer
  
  def show
  end

  def me
    @user = @current_user
    render :action => 'show'
  end

  def edit
  end

  def update
    # We use the negative form to ease the view.
    @wrong_password = false
    if @user == @current_user && !User.authenticate(@current_account, @current_user.email, params[:current_password])
      @wrong_password = true
    end

    @user.attributes = params[:user]
    # Run validations even if the password was wrong.
    if @user.valid? && !@wrong_password && @user.save
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url
  end

protected

  def find_user
    begin
      @user = @current_account.users.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to users_url
    end
  end

  def protect_roles
    if admin? && @current_user == @user
      # An admin cannot uncheck himslef.
      params[:user].delete(:administrator)
    elsif !admin?
      # A non-admin can edit no role.
      params[:user].delete(:administrator)
      params[:user].delete(:salesman)
    end
  end

  def require_admin
    redirect_to offers_url unless admin?
  end

  def require_admin_or_me
    redirect_to offers_url unless admin? or @current_user == @user
  end
end
