Rails.application.routes.draw do

  get "/" => "homes#top", as: "top"
  get "/about" => "homes#about", as: "about"
  devise_for :users

  resources :users, only: [:show, :index, :edit, :update]

  resources :spots do
    resources :comments, only: [:create, :destroy]
  end

end
