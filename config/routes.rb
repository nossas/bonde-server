Rails.application.routes.draw do
  resources :mobilizations, only: [:index] do
    resources :blocks, controller: 'mobilizations/blocks', only: [:index, :create, :update]
    resources :widgets, controller: 'mobilizations/widgets', only: [:index]
  end
  mount_devise_token_auth_for 'User', at: '/auth'
end
