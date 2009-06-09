require 'set'

class ForecastsController < ApplicationController
  MONTH_NAMES = %w(
    Enero
    Febrero
    Marzo
    Abril
    Mayo
    Junio
    Julio
    Agosto
    Septiembre
    Octubre
    Noviembre
    Diciembre
  )

  before_filter :determine_scope
  before_filter :require_admin, :only => [:pipeline_per_salesman, :pipeline_per_salesman_graph, :weighted_pipeline_per_salesman_graph]
  before_filter :find_user, :only => [:pipeline_per_salesman, :pipeline_per_salesman_graph, :weighted_pipeline_per_salesman_graph]

  def index
    @pipeline_size = @scope.pipeline.size
    unless @pipeline_size.zero?
      @pipeline_per_status = chart_object(pipeline_per_status_graph_forecasts_path)
      @pipeline_per_salesman = chart_object(pipeline_per_salesman_graph_forecasts_path)
    end
  end

  def pipeline_per_status
    path = weighted? ? weighted_pipeline_per_status_graph_forecasts_path : pipeline_per_status_graph_forecasts_path
    render :partial => 'pipeline_per_status', :locals => {:graph => chart_object(path)}
  end

  def pipeline_per_status_graph
    pipeline_graph_generator('Pipeline por estado (sin ponderar)', @scope.pipeline, :status, :amount)
  end

  def weighted_pipeline_per_status_graph
    pipeline_graph_generator('Pipeline por estado (ponderado)', @scope.pipeline, :status, :weighted_amount)
  end

  def pipeline_per_salesman
    path = {}
    path[:user_id] = @user.id if @user
    path[:action] = weighted? ?  :weighted_pipeline_per_salesman_graph : :pipeline_per_salesman_graph
    render :partial => 'pipeline_per_salesman', :locals => {:graph => chart_object(url_for(path))}
  end

  def pipeline_per_salesman_graph
    pipeline  = @user ? @user.pipeline : @scope.pipeline
    title     = @user ? "Pipeline de #{@user.name} (sin ponderar)" : 'Pipeline por comercial (sin ponderar)'
    max_y_for = @user ? @scope.pipeline : nil
    pipeline_graph_generator(title, pipeline, :salesman, :amount, max_y_for)
  end

  def weighted_pipeline_per_salesman_graph
    pipeline  = @user ? @user.pipeline : @scope.pipeline
    title     = @user ? "Pipeline de #{@user.name} (ponderado)" : 'Pipeline por comercial (ponderado)'
    max_y_for = @user ? @scope.pipeline : nil
    pipeline_graph_generator(title, pipeline, :salesman, :weighted_amount, max_y_for)
  end

protected

  def weighted?
    params[:weighted] == '1'
  end

  def pipeline_graph_generator(title, pipeline, classifier, offer_attribute_to_add, max_y_for=nil)
    # Classify offers by month.
    per_month = Set.new(pipeline).classify {|p| date_key(p.deal_date)}
    per_month = {date_key(Date.today) => Set.new} if pipeline.size.zero?
    last_month = per_month.keys.sort.last

    # Iterate over per_month to fill missing months with empty sets.
    n = 0
    loop do
      since = date_key(n.months.since)
      break if since > last_month
      per_month[since] = Set.new unless per_month.key?(since)
      n += 1
    end

    g = OpenFlashChart.new
    g.title = Title.new(title)
    g.set_bg_colour('#ffffff')
    g.set_is_decimal_separator_comma(true)

    bar_stack = BarStack.new
    labels = []
    max_y = 0
    per_month.keys.sort.each do |key|
      labels << "#{MONTH_NAMES[key.last-1]} #{key.first}"
      offers_per_record = per_month[key].classify(&classifier)
      values = []
      bar_values = []
      @current_account.send(classifier.to_s.pluralize).reverse.each do |record|
        value = offers_per_record[record].map(&offer_attribute_to_add).sum rescue 0
        values << value
        bar_value = BarStackValue.new(value, record.color)
        bar_values << bar_value
      end
      max_y = [max_y, values.sum].max
      bar_stack.append_stack(bar_values)
    end
    g.add_element(bar_stack)

    # set X axis
    x_axis = XAxis.new
    x_axis.set_labels(labels)
    g.set_x_axis(x_axis)

    # set Y axis
    y_axis = YAxis.new
    max_y = 10 if max_y.zero?
    y_axis.set_range(0, ymax(max_y), ymax(max_y)/10)
    g.set_y_axis(y_axis)

    render :text => g.render
  end

  def determine_scope
    @scope = admin? ? @current_account : @current_user
  end

  def find_user
    return if params[:user_id].blank?
    begin
      @user = @current_account.users.find(params[:user_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to forecasts_url
    end
  end

  def require_admin
    redirect_to offers_url unless admin?
  end

  def ymax(max)
    nzeros = max.to_i.to_s.size - 1
    base = 10**nzeros
    ymax = max + base
    ymax -= ymax % base
    ymax
  end

  # Returns an array to be used as a hash key in classifications for pipelines.
  def date_key(date_or_ts)
    d = date_or_ts.to_date
    [d.year, d.month]
  end

  def chart_object(path)
    open_flash_chart_object(650, 300, path, false)
  end
end
