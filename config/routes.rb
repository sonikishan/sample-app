SampleApp::Application.routes.draw do
  get "relationships/create"

  get "relationships/destroy"

  get "microposts/create"

  get "microposts/destroy"

  get "sessions/new"

  resources :users do
    member do
      get :followers, :following
    end
  end

  # Adding the resources :users line creates the following named routes automagically:

  # REQUEST    URL             ACTION      NAMED ROUTE
  # --------------------------------------------------------
  # GET        /users          index       users_path
  # GET        /users/1        show        users_path(1)
  # GET        /users/new      new         new_user_path
  # POST       /users          create      users_path
  # GET        /users/1/edit   edit        edit_user_path(1)
  # PUT        /users/1        update      user_path(1)
  # DELETE     /users/1        destroy     user_path(1)

  # Adding the member do... block creates the following named routes:

  # REQUEST    URL                  ACTION      NAMED ROUTE
  # --------------------------------------------------------
  # GET        /users/1/following   following   following_user_path(1)
  # GET        /users/1/followers   followers   followers_user_path(1)

  resources :sessions, :only => [:new, :create, :destroy]

  # REQUEST    URL             ACTION      NAMED ROUTE
  # --------------------------------------------------------
  # GET        /signin         new         signin_path
  # POST       /sessions       create      session_path
  # DELETE     /signout        destroy     signout_path

  resources :microposts, :only => [:create, :destroy]

  # REQUEST    URL             ACTION      NAMED ROUTE
  # --------------------------------------------------------
  # POST       /microposts     create      micropost_path
  # DELETE     /microposts/1   destroy     micropost_path(1)

  resources :relationships, :only => [:create, :destroy]

  match '/contact', :to => 'pages#contact'
  match '/about',   :to => 'pages#about'
  match '/help',    :to => 'pages#help'

  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

  match '/signup',  :to => 'users#new'

  root              :to => 'pages#home'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
#== Route Map
# Generated on 10 Sep 2012 16:04
#
# microposts_destroy GET    /microposts/destroy(.:format)  microposts#destroy
#       sessions_new GET    /sessions/new(.:format)        sessions#new
#     followers_user GET    /users/:id/followers(.:format) users#followers
#     following_user GET    /users/:id/following(.:format) users#following
#              users GET    /users(.:format)               users#index
#                    POST   /users(.:format)               users#create
#           new_user GET    /users/new(.:format)           users#new
#          edit_user GET    /users/:id/edit(.:format)      users#edit
#               user GET    /users/:id(.:format)           users#show
#                    PUT    /users/:id(.:format)           users#update
#                    DELETE /users/:id(.:format)           users#destroy
#           sessions POST   /sessions(.:format)            sessions#create
#        new_session GET    /sessions/new(.:format)        sessions#new
#            session DELETE /sessions/:id(.:format)        sessions#destroy
#         microposts POST   /microposts(.:format)          microposts#create
#          micropost DELETE /microposts/:id(.:format)      microposts#destroy
#            contact        /contact(.:format)             pages#contact
#              about        /about(.:format)               pages#about
#               help        /help(.:format)                pages#help
#             signin        /signin(.:format)              sessions#new
#            signout        /signout(.:format)             sessions#destroy
#             signup        /signup(.:format)              users#new
#               root        /                              pages#home
