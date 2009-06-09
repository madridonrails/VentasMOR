class StatusesController < ApplicationController
  before_filter :require_admin, :except => :index
  before_filter :find_statuses, :only => [:index, :reorder]
  before_filter :find_status, :only => [:show, :edit, :update, :destroy]

  def index
  end

  def new
    @status = @current_account.custom_statuses.build
  end

  def create
    @status = @current_account.custom_statuses.build(params[:custom_status])
    if @status.save
      redirect_to statuses_url
    else
      render :action => 'new'
    end
  end

  def show
  end

  def won
    @status = @current_account.won_status
    render :action => 'show'
  end

  def lost
    @status = @current_account.lost_status
    render :action => 'show'
  end

  def edit
  end

  def update
    if @status.update_attributes(params[:custom_status])
      redirect_to statuses_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @status.destroy
    redirect_to statuses_url
  end

  def reorder
    if request.xhr?
      @statuses.each do |s|
        # assign by hand because "position" is protected
        s.position = params['status-list'].index(s.id.to_s) + 1
        s.save(false)
      end
    end
  end

protected

  def find_statuses
    @statuses = @current_account.statuses
  end

  def find_status
    begin
      @status = @current_account.statuses.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to statuses_url
    end
  end

  def require_admin
    redirect_to statuses_url unless admin?
  end
end
