ForYourConsideration::Application.routes.draw do
  match '/auth/:provider/callback', to: 'sessions#create'
  root to: 'pages#landing'
  get 'search' => 'pages#search'
end
