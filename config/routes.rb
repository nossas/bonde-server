Rails.application.routes.draw do
  resources :mobilizations, only: [:index, :create, :update] do
    get :published, on: :collection
    resources :blocks, controller: 'mobilizations/blocks', only: [:index, :create, :update, :destroy]
    resources :widgets, controller: 'mobilizations/widgets', only: [:index, :update]
    resources :form_entries, controller: 'mobilizations/form_entries', only: [:create]
    resources :donations, controller: 'mobilizations/donations', only: [:create]
  end

  resources :blocks, only: [:index]
  resources :widgets, only: [:index] do
    get :action_opportunities, on: :collection
  end
  resources :uploads, only: [:index]
  resources :organizations, only: [:index]
  mount_devise_token_auth_for 'User', at: '/auth'
end
