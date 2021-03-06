Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api, defaults: {format: :json} do 
    namespace :v1 do 
      resources :users do 
        get :buzzfeed, on: :member
      end
      resources :sessions, only: [:create, :destroy]
      resources :emergencies, only: [:show] do 
        post :create_destination, on: :collection
        member do
          post :create_origin
          put :update_location
          put :switch_traffic_light
          get :traffic_light_details
        end
      end
    end
  end
end
