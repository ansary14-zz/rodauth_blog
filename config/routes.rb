Rails.application.routes.draw do
  root to: "home#index"
  resources :posts

  controller :rodauth do
    get "download-recovery-codes"
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
