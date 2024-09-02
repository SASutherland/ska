Rails.application.routes.draw do
  devise_for :users

  get 'dashboards/index'
  post 'register_for_course', to: 'dashboards#register_for_course', as: 'register_for_course'

  resources :courses do
    resources :questions, only: [:show]
  end

  root to: "pages#home"
end
