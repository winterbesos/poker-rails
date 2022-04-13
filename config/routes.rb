Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :card_tables, only: [:index, :show] do 
    post "play-events", to: 'card_tables#play'
    post "pass-events", to: 'card_tables#pass'
    post "replay-events", to: 'card_tables#replay'
    post "show-events", to: 'card_tables#show_team'

    post "stand-events", to: 'card_tables#stand'
    post "sit-events", to: 'card_tables#sit'
  end

  resources :board_games, only: [:index, :show] do
  end
end
