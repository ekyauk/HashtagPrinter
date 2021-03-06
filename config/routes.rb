Rails.application.routes.draw do
  devise_for :users, :controllers => {
    :omniauth_callbacks => 'users/omniauth_callbacks'
   }

  get 'printers/', to: 'printers#index'
  get 'printers/info/:id', to: 'printers#info'
  get 'users/add_printer/:id', to: 'users#add_printer'
  get 'users/deselect_printer', to: 'users#add_printer'
  get 'users/save_to_gdrive', to: 'users#change_save_to_gdrive'

  get 'users/index', to: 'users#index'
  post 'hashtags/create', to: 'hashtags#create'
  get 'hashtags/callback/:id', to: 'hashtags#callback'
  post 'hashtags/callback/:id', to: 'hashtags#print_photo'
  get 'hashtags/delete/:id', to: 'hashtags#delete'
  get 'hashtags/delete', to: 'hashtags#delete'
  get 'users/new', to: 'users#new', as: :new_user

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'users#index'
  # get '/auth/:provider/callback', to: 'users#index'
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
