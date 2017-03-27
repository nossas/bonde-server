Rails.application.routes.draw do
  post '/postbacks' => 'postbacks#create', as: :create_postback
  resources :notifications, only: [:show]
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
  resources :communities, only: [:index, :create, :update, :show] do
    resources :dns_hosted_zones, except: [:new, :edit] do
      get 'check', to: 'dns_hosted_zones#check'
      resources :dns_records, except: [:new, :edit]
    end
    resources :activist_actions, only: [:index], controller: 'communities/activist_actions'
    resources :payable_details, only: [:index], controller: 'communities/payable_details'
    resources :donation_reports, only: [:index], controller: 'communities/donation_reports'
    resources :community_users, path: 'users', only: [:index, :create, :update]
    get 'mobilizations', to: 'communities#list_mobilizations'
    get 'activists', to: 'communities#list_activists'
    post 'activists', to: 'activists#add_activists'
    post 'invitation', to: 'communities#create_invitation'
  end

  resources :users, only: [:create, :update]
  resources :subscriptions do
    post :recharge, on: :member
  end

  post '/invitation', to: 'communities#accept_invitation', as: 'accept_invitation'
  get '/convert-donation/:user_email/:widget_id' =>  'convert_donations#convert'

  mount_devise_token_auth_for 'User', at: '/auth'
end
