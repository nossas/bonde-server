Rails.application.routes.draw do
  resources :mobilizations, only: [:index] do
    resources :blocks, controller: 'mobilizations/blocks', only: [:index, :create, :update, :destroy]
    resources :widgets, controller: 'mobilizations/widgets', only: [:index, :update]
  end
  resources :uploads, only: [:index]
  mount_devise_token_auth_for 'User', at: '/auth'
end
