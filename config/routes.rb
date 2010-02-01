ActionController::Routing::Routes.draw do |map|

  map.namespace :admin do |admin|
    admin.resources :admin_users
    admin.resources :authorities
    admin.resources :new_informations
    admin.resources :recommend_products, :collection => {:product_search => [:get]}
    admin.resources :questionnaires
    admin.resources :campaigns, :member => {:campaign_design => [:get]}
    admin.resources :shops, :only => [:destroy, :index]
    admin.resources :mail_magazines, :collection => {:history => [:get], :search => [:get]}
    admin.resources :mail_magazine_templates
    admin.resources :features
    admin.resources :feature_products, :collection => {:product_search => [:get]}
    admin.resources :mobile_devices, :collection => {:search => [:get]}
    admin.resources :customers, :collection => {:get_address => [:get], :search => [:get]}
    admin.resources :orders, :collection => {:get_address => [:get], :search => [:get]}, :member => {:edit => [:get, :put]}
    admin.resources :order_statuses
    admin.resources :products, :collection => {:search => [:get], :actual_count_index => [:get], :actual_count_search => [:get]}
    admin.resources :product_styles
    admin.resources :categories
    admin.resources :styles
    admin.resources :style_categories
  end

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => 'portal', :action => 'show'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect 'product/category/:category_id', :controller => 'product', :action => 'index'
  map.connect 'image_resource/:action/:id/image.jpg', :controller => 'image_resource'

  map.connect 'admin/', :controller => '/admin/home', :action => 'index'

  map.connect 'campaigns/complete/:id', :controller => 'campaigns', :action => 'complete'
  map.connect 'campaigns/:dir_name', :controller => 'campaigns', :action => 'show', :requirements => {:dir_name => /.*/ }
  map.connect 'accounts/activate/:activation_key', :controller => 'accounts', :action => 'activate'
  map.connect 'features/:dir_name', :controller => 'features', :action => 'show', :requirements => {:dir_name => /.*/ }

  # cart
  map.connect 'cart', :controller => 'cart', :action => 'show'

  # my page
  map.connect 'accounts', :controller => 'accounts', :action => 'history'

  # javascript
  map.js 'js/:action.js', :controller => 'javascript'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
