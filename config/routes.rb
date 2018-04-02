Rails.application.routes.draw do

  root 'pages#home'
  resources :games
  get '/snowboard', to: 'pages#snowboard'
  get 'current_user', to: "games#get_current_user"

  mount ActionCable.server => '/cable'

  post '/games/random', to: 'games#random_game', as: 'random'

  post '/games/:id/invite', to: 'games#invite', as: 'invite'
  delete '/games/:id/uninvite', to: 'games#uninvite', as: 'uninvite'

  post '/games/:id/send_invites', to: 'games#send_invites', as: 'send_invites'
  post '/games/:id/join', to: 'games#join', as: 'join'

  post '/games/:id/actions', to: 'games#actions', as: 'actions'
  delete '/games/:id/cancel_action', to: 'games#cancel_action', as: 'cancel_action'
  post '/games/:id/timer_update', to: 'games#timer_update', as: 'timer_update'
  post '/games/:id/map', to: 'games#map', as: 'map'

  post '/read', to: 'messages#read', as: 'read'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
