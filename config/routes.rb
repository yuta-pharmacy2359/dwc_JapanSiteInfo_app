Rails.application.routes.draw do

  get "/" => "homes#top", as: "top"
  get "/about" => "homes#about", as: "about"
  devise_for :users

  resources :users, only: [:show, :index, :edit, :update] do
    member do
      get :following, :followers
    end
  end

  resources :spots do
    resources :comments, only: [:create, :destroy]
    resource :favorites, only: [:create, :destroy]
  end

  resources :follow_relationships, only: [:create, :destroy]

  resources :keywords, only: [:show, :index]

  get "/rankings/user_favorite" => "rankings#user_favorite", as: "user_favorite_ranking"
  get "/rankings/spot_favorite" => "rankings#spot_favorite", as: "spot_favorite_ranking"

end
