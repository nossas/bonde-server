Rails.application.routes.draw do
  resources :mobilizations, only: [:index, :create, :update] do
    get :published, on: :collection
    resources :blocks, controller: 'mobilizations/blocks', only: [:index, :create, :update, :destroy]
    resources :widgets, controller: 'mobilizations/widgets', only: [:index, :update]
    resources :form_entries, controller: 'mobilizations/form_entries', only: [:create, :index]
    resources :donations, controller: 'mobilizations/donations', only: [:create, :index]
  end
  
  resources :template_mobilizations, only: [:index, :destroy, :create], path: '/templates' do
  end

  resources :blocks, only: [:index]
  resources :widgets, only: [:index] do
    get :action_opportunities, on: :collection
    resources :match, controller: 'widgets/match', only: [:create, :update, :show, :destroy] do
      delete 'delete_where', on: :collection
    end
    resources :fill, controller: 'widgets/fill', only: [:create]
  end

  resources :activist_matches, only: [:create]
  resources :uploads, only: [:index]
  resources :organizations, only: [:index] do
    resources :payable_details, only: [:index], controller: 'organizations/payable_details'
  end

  resources :users, only: [:create, :update]
  
  mount_devise_token_auth_for 'User', at: '/auth'
end
