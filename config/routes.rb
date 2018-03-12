Rails.application.routes.draw do

  root 'pages#home'
  resources :games

  mount ActionCable.server => '/cable'

  get '/games/:id/invite_friends', to: 'games#invite_friends', as: 'invite_friends'
  post '/games/:id/invite', to: 'games#invite', as: 'invite'
  delete '/games/:id/uninvite', to: 'games#uninvite', as: 'uninvite'

  post '/games/random', to: 'games#random_game', as: 'random'

  get '/games/:id/pending', to: 'games#pending_game', as: 'pending_game'

  post '/games/:id/join', to: 'games#join', as: 'join'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
