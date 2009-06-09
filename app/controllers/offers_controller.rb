# FIXME: amount, status, and deal_date use render :update, factor them out to templates
class OffersController < ApplicationController
  layout 'offer'
  include FormatterHelper

  before_filter :determine_scope, :except => :export
  before_filter :find_offer, :only => [:show, :edit, :update, :destroy, :amount, :status, :deal_date]
  skip_before_filter :compute_totals_for_sidebar, :only => [:amount, :status, :deal_date]

  def index
    @current_order_by = order_by(6, 5)
    @current_direction = direction('DESC')
    respond_to do |wants|
      wants.html do
        @offers = params[:search].blank? ? regular_index : search_index
        render :action => 'index.html.erb', :layout => 'application'
      end
      wants.csv do
        render_as_csv(
          @scope.scoped(
            :order      => 'offers.deal_date DESC',
            :conditions => period_conditions.merge(customer_conditions)
        ))
      end
    end
  end

  def closed
    index
  end

  def open
    index
  end

  def regular_index
    # We do not include the salesman because will_paginate triggers a COUNT call
    # and there's this problem related to table aliasing:
    #
    #    http://rails.lighthouseapp.com/projects/8994/tickets/302-association-count-with-include-doesn-t-alias-join-table
    #
    # In our case Account has_many :offers, :through => :users generates an
    # INNER JOIN, and :include => :salesman generates an OUTER JOIN, and they
    # clash because of that bug.
    incl = [:customer, :status]
    incl << :salesman unless admin? # if the account is not involved we actually need this to be able to order by salesman
    @scope.paginate(
      :all,
      :page => params[:page],
      :include => incl,
      :order => [
        "customers.name_normalized #@current_direction",
        "offers.name_normalized #@current_direction",
        "users.name_normalized #@current_direction",
        "offers.amount #@current_direction",
        "statuses.name_normalized #@current_direction",
        "offers.deal_date #@current_direction"
      ][@current_order_by]
    )
  end
  protected :regular_index

  def search_index
    logger.debug("search index")
    @scope_for_caption = %Q{por "#{params[:search]}"}
    conditions = admin? ? {:account_id => @current_account.id} : {:salesman_id => @current_user.id}
    Offer.search(
      params[:search],
      :page       => params[:page],
      :per_page   => Config.pagination_window,
      :conditions => conditions,
      :order      => [:customer_name, :name, :salesman_name, :amount, :status_name, :deal_date][@current_order_by],
      :sort_mode  => @current_direction.downcase.to_sym
    )
  end
  protected :search_index

  def by_name
    name = VentasgemUtils.normalize_for_db(params[:name])
    conditions = ['offers.name_normalized LIKE ?', "%#{name}%"]
    conditions[0] << " AND offers.salesman_id = #{@current_user.id}" unless admin?
    @completions = @scope.find(
      :all,
      :conditions => conditions,
      :order      => 'offers.name_normalized ASC',
      :limit      => 10
    )
    render :partial => 'shared/completions'
  end

  def new
    unless params[:copy].blank?
      begin
        @offer = @scope.find(params[:copy]).clone
      rescue
        redirect_to new_offer_url
      end
      return
    end
    @offer = Offer.new

    # Choose default salesman.
    @offer.salesman = @current_user if @current_user.salesman?
    if params.key?(:user_id)
      # /users/:user_id/offers/new
      begin
        user = @current_account.users.find(params[:user_id])
        @offer.salesman = user if admin?
      rescue ActiveRecord::RecordNotFound
        # ignore, perhaps a race condition with user deletion (if it is provided someday)
      end
    end

    # Choose default customer.
    if params.key?(:customer_id)
      # /customers/:customer_id/offers/new
      begin
        @offer.customer = @current_account.customers.find(params[:customer_id])
      rescue ActiveRecord::RecordNotFound
        # ignore, perhaps a race condition with customer deletion
      end
    end
  end

  def create
    @offer = Offer.new(params[:offer])
    if @offer.assign_protected_stuff(@current_account, @current_user, params[:offer])
      logger.debug(@offer.to_xml)
      redirect_to(@offer) and return if @offer.save
    else
      # Either ID injection or a race condition if a salesman was just deleted,
      # let validations run at least.
      @offer.valid?
    end
    render :action => 'new'
  end

  def show
    redirect_to @offer if request.post? # completion in paginator
  end

  def edit
  end

  def update
    if @offer.assign_protected_stuff(@current_account, @current_user, params[:offer])
      redirect_to(@offer) and return if @offer.update_attributes(params[:offer])
    else
      # Either ID injection or a race condition if a salesman was just deleted,
      # let validations run at least.
      @offer.valid?
    end
    render :action => 'edit'
  end

  def destroy
    @offer.destroy
    redirect_to offers_url
  end

  def amount
    if request.method == :get
      render :partial => 'amount_form'
    else
      @offer.update_attribute(:amount, params[:offer][:amount])
      compute_totals_for_sidebar
      render :update do |page|
        page.replace dom_id(@offer, :amount), :partial => 'amount', :locals => {:offer => @offer}
        page.replace 'top-status', :partial => 'shared/top_status'
      end
    end
  end
  xhr_only :amount

  def status
    if request.method == :get
      render :partial => 'status_form'
    else
      if @current_account.statuses.exists?(params[:offer][:status_id])
        @offer.update_attribute(:status_id, params[:offer][:status_id])
      end
      compute_totals_for_sidebar
      render :update do |page|
        page.replace dom_id(@offer, :status), :partial => 'status', :locals => {:offer => @offer}
        page.replace 'top-status', :partial => 'shared/top_status'
      end
    end
  end
  xhr_only :status

  def deal_date
    if request.method == :get
      render :partial => 'deal_date_form'
    else
      @offer.deal_date_as_string = params[:offer][:deal_date_as_string]
      @offer.save
      compute_totals_for_sidebar
      render :update do |page|
        page.replace dom_id(@offer, :deal_date), :partial => 'deal_date', :locals => {:offer => @offer}
        page.replace 'top-status', :partial => 'shared/top_status'
      end
    end
  end
  xhr_only :deal_date

  def export
    @customers = @current_account.customers.all(:order => 'name_normalized ASC')
    render :action => 'export', :layout => 'application'
  end

protected

  def determine_scope
    target = admin? ? @current_account : @current_user
    if @current_action == 'open'
      @scope             = target.offers.open
      @scope_for_caption = 'en curso'
    elsif @current_action == 'closed'
      @scope             = target.offers.closed
      @scope_for_caption = 'cerradas'
    else
      # We do now some dynamic stuff to avoid duplication.
      %w(customer user status).each do |key|
        scope_key = "#{key}_id"
        unless params[scope_key].blank?
          object             = @current_account.send(key.pluralize).find(params[scope_key]) # object needed for caption
          object_fk          = key == 'user' ? 'salesman_id' : scope_key
          @scope             = target.offers.scoped(:conditions => {"offers.#{object_fk}" => object.id})
          @scope_key         = scope_key
          @scope_value       = params[scope_key]
          @scope_for_caption = key == 'status' ? %Q(en estado "#{object.name}") : "de #{object.name}"
          return
        end
      end
      @scope       = target.offers
      @scope_key   = nil
      @scope_value = nil
    end
  rescue ActiveRecord::RecordNotFound
    # For whatever reason the scope object those not exist. That may be a race
    # condition (someone deleted it in parallel), an attempt to manipulate the
    # ID, or whatever.
    redirect_to offers_url
  end

  def find_offer
    @offer = @scope.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to offers_url
  end

  def render_as_csv(offers)
    # These charsets are expected to be common in our users.
    charset = (request_from_a_mac? ? "MacRoman" : "ISO-8859-1")
    norm = lambda {|o| Iconv.conv("#{charset}//IGNORE", "UTF-8", o.to_s) rescue o.to_s}
    col_sep = ';'                                     # Excel understands this one automatically
    row_sep = (request_from_windows? ? "\r\n" : "\n") # in case people treat it as a text file

    csv_string = FasterCSV.generate(:col_sep => col_sep, :row_sep => row_sep) do |csv|
      csv << ['Oferta', 'Estado', 'Probabilidad', 'Cliente', 'Comercial', 'Fecha Cierre', 'Año', 'Mes', 'Día', 'Importe', 'Importe Ponderado'].map {|h| norm.call(h)}
      # The find_each iterator is provided by pseudo_cursors.
      offers.find_each(:order => 'deal_date DESC') do |offer|
        csv << [
          norm.call(offer.name),
          norm.call(offer.status.name),
          offer.weight,
          offer.customer.name,
          offer.salesman.name,
          format_date(offer.deal_date),
          offer.deal_date.year,
          offer.deal_date.month,
          offer.deal_date.day,
          offer.amount,
          offer.weighted_amount
        ].map {|field| norm.call(field)}
      end
    end
    send_data(csv_string, :type => "text/csv; charset=#{charset}", :filename => "ofertas_#{Time.now.strftime("%Y%m%d")}.csv")
  end

  def period_conditions
    today = Date.today
    case params[:period]
      when 'current_quarter'
        date_from = today.beginning_of_quarter
        date_to   = today.end_of_quarter
        {:deal_date => date_from..date_to}
      when 'last_quarter'
        three_months_ago = today.months_ago(3)
        date_from = three_months_ago.beginning_of_quarter
        date_to   = three_months_ago.end_of_quarter
        {:deal_date => date_from..date_to}
      when 'current_year'
        {:deal_date => today.beginning_of_year..today}
      when 'last_year'
        last_year = today.last_year
        {:deal_date => last_year.beginning_of_year..last_year.end_of_year}
      else
        {}
    end
  end

  def customer_conditions
    params[:customer_id].blank? ? {} : {:customer_id => params[:customer_id]}
  end
end
