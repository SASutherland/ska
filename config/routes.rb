Rails.application.routes.draw do
  devise_for :users

  get 'dashboard', to: 'dashboards#index', as: 'dashboard'

  post 'register_for_course', to: 'dashboards#register_for_course', as: 'register_for_course'

  resources :courses, only: [:new, :create, :index, :edit, :update, :destroy] do

    collection do
      get :my_courses
    end

    member do
      delete 'unenroll', to: 'courses#unenroll'
    end

    resources :questions, only: [:show] do
      post 'submit_answer', on: :member
    end
    
  end

  root to: "pages#home"
end
