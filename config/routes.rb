Rails.application.routes.draw do

  get "/" => "homes#top", as: "top"
  get "/about" => "homes#about", as: "about"
  devise_for :users

end
