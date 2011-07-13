ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  map.index '/index', :controller => 'say'
  map.admin '/admin', :controller => 'admin', :action => 'admin_page'
  map.login '/admin/login', :controller => 'admin', :action => 'login'
  map.logout '/admin/logout', :controller => 'admin', :action => 'logout'
  map.course '/course', :controller => 'course', :action => 'navigate'
  map.search '/search', :controller => 'say', :action => 'hello'
  map.course_view '/course/view', :controller => 'course', :action => 'view'
  map.course_search '/course/search', :controller => 'course', :action => 'search'
  map.advBook_search '/search/Book', :controller => 'say', :action => 'advanced_search'
  map.advArticle_search '/search/article', :controller => 'say', :action => 'ad_article'
  map.addnew '/course/new_select', :controller => 'course', :action => 'new_select'
  map.adminview '/course/view', :controller => 'course', :action => 'view', :option =>'view'
  map.update '/course/update', :controller => 'course', :action => 'view', :option => 'update'
  map.fullview '/course/fullview', :controller => 'course', :action => 'view_all'
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
  #map.root :controller => "say", :action => "hello"
  map.root :controller => "say"
  
  # See how all your routes lay out with "rake routes"
  
  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
