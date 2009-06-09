ActionController::Routing::Routes.draw do |map|
  map.resources :accounts,
    :collection => {:available => :get}

  map.resources :offers,
    :member => {:amount => :any, :status => :any, :deal_date => :any},
    :collection => {:closed => :get, :open => :get, :by_name => :get, :export => :get}

  map.resources :customers,
    :has_many => :offers,
    :collection => {:by_name => :get, :create_for_offer => :post}

  map.resources :users,
    :has_many => :offers,
    :collection => {:by_name => :get, :me => :get, :create_for_offer => :post}

  map.statuses_edit 'statuses/edit', :controller => 'statuses', :action => 'edit_list'
  map.statuses_reorder 'statuses/reorder', :controller => 'statuses', :action => 'reorder'
  map.won_status 'statuses/won', :controller => 'statuses', :action => 'won'
  map.lost_status 'statuses/lost', :controller => 'statuses', :action => 'lost'
  map.resources :statuses, :collection => {:won => :get, :lost => :get}
  map.resources :custom_statuses, :as => :statuses

  map.resources :forecasts,
    :collection => {
      :pipeline_per_status                  => :get,
      :pipeline_per_status_graph            => :get,

      :weighted_pipeline_per_status         => :get,
      :weighted_pipeline_per_status_graph   => :get,

      :pipeline_per_salesman                => :get,
      :pipeline_per_salesman_graph          => :get,

      :weighted_pipeline_per_salesman       => :get,
      :weighted_pipeline_per_salesman_graph => :get
    }

  map.resources :reports,
    :collection => {
      :payments_per_week => :get
    }

  map.resource :session, :controller => 'session', :collection => {:lost_password => :any}

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "public", :action => 'index', :conditions => {:subdomain => 'www'}
  map.root :controller => 'offers', :action => 'open'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
