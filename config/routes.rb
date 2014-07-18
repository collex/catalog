Rails.application.routes.draw do
	resources :archives, :only => [:index, :create, :edit, :destroy, :update] do
		collection do
			get 'category_list'
			get 'tree'
			get 'toggle_testing'
		end
	end

	resources :federations
	resources :genres
	resources :disciplines
	
	post '/corrections' => 'corrections#create'

	resources :exhibits, :only => [:index, :create, :destroy] do
		collection do
			get 'test_create_good'
			get 'test_create_bad'
			get 'test_destroy_good'
			get 'test_destroy_bad'
		end
	end

	resources :locals, :only => [:index, :create, :destroy, :update ] do
		collection do
			get 'test_search_good'
			get 'test_search_bad'
		end
	end

	devise_for :users

	get "home/index"

	resources :search, :only => [:index] do
		collection do
			get 'autocomplete'
			get 'names'
			get 'totals'
			get 'details'
      get 'languages'
		end
	end

	resources :test_sort, :only => [:index]

  # The priority is based upon order of creation:
  # first created -> highest priority.

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

  # You can have the root of your site routed with "root"
  root :to => "home#index"
	post "/" => "home#index"

  # See how all your routes lay out with "rake routes"
end
