class CustomersController < ApplicationController
  before_filter :find_customer, :except => [:index, :by_name, :new, :create, :create_for_offer]

  def index
    @current_order_by = 0
    @current_direction = direction
    @customers = @current_account.customers.paginate(:order => "name_normalized #@current_direction", :page => params[:page])
  end

  def new
    @customer = @current_account.customers.build
  end

  def create
    @customer = @current_account.customers.build(params[:customer])
    @customer.build_address(params[:address])
    if @customer.save
      redirect_to customers_url
    else
      render :action => 'new'
    end
  end

  # This action is called from the redbox in the offer forms. It responds
  # only to POST and xhr.
  def create_for_offer
    @customer = @current_account.customers.build(params[:customer])
    @customer.build_address(params[:address])
    if @customer.save
      # Create dummy objects to be able to rebuild the customer selector.
      @offer = @current_account.offers.build
      @offer.customer = @customer
    end
  end
  xhr_only :create_for_offer

  def by_name
    name = VentasgemUtils.normalize_for_db(params[:name])
    @completions = @current_account.customers.find(
      :all,
      :conditions => ['name_normalized LIKE ?', "%#{name}%"],
      :order      => 'name_normalized ASC',
      :limit      => 10
    )
    render :partial => 'shared/completions'
  end

  def show
    redirect_to @customer if request.post? # completion in paginator
    @offers = @customer.offers.select {|o| @current_user.can_see_offer?(o)}
  end

  def update
    begin
      Customer.transaction do
        @customer.update_attributes!(params[:customer])
        @customer.address.update_attributes!(params[:address])
      end
    rescue
      render :action => 'edit'
    else
      # We need to do this once the transaction has been committed.
      @customer.thinking_sphinx_reindex_offers
      redirect_to customers_url
    end
  end

  def destroy
    @customer.destroy
    redirect_to customers_url
  end

  def find_customer
    begin
      @customer = @current_account.customers.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to customers_url
    end
  end
  protected :find_customer
end
