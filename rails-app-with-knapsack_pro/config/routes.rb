Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :articles
  resources :calculator, only: [:index, :create]

  root 'welcome#index'
end
