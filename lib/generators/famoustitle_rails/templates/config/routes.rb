Rails.application.routes.draw do
  devise_for :users,
  defaults: { format: :json },
  controllers: {
      sessions: 'sessions',
      registrations: 'registrations'
  }

  resources :uploads, only: [:index, :create, :destroy]

  resources :avatars, only: [:create]
  
  post "/graphql", to: "graphql#execute"
end
