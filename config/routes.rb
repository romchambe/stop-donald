Rails.application.routes.draw do

  root 'pages#home'
  resources :games

  get 'current_user', to: "games#get_current_user"

  mount ActionCable.server => '/cable'

  post '/games/random', to: 'games#random_game', as: 'random'

  post '/games/:id/invite', to: 'games#invite', as: 'invite'
  delete '/games/:id/uninvite', to: 'games#uninvite', as: 'uninvite'

  post '/games/:id/send_invites', to: 'games#send_invites', as: 'send_invites'
  post '/games/:id/join', to: 'games#join', as: 'join'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
