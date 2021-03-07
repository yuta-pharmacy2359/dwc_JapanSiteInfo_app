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

end
