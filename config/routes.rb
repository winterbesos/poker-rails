Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post "sit-events", to: 'card_tables#sit'
  get "tables", to: "card_tables#index"

  resources :card_tables, only: [:show] do 
    post "play-events", to: 'card_tables#play'
    post "pass-events", to: 'card_tables#pass'
    post "replay-events", to: 'card_tables#replay'
    post "show-events", to: 'card_tables#show_team'
  end

  resources :board_games, only: [:index, :show] do
  end
end
