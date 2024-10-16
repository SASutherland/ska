Rails.application.routes.draw do
  devise_for :users

  get "dashboard", to: "dashboards#index", as: "dashboard"
  get "dashboard/groepen", to: "dashboards#my_groups", as: "dashboard_my_groups"

  post "register_for_course", to: "dashboards#register_for_course", as: "register_for_course"

  resources :courses, only: [:new, :create, :index, :edit, :update, :destroy] do
    collection do
      get :my_courses
    end

    member do
      delete "unenroll", to: "courses#unenroll"
    end

    resources :questions, only: [:show] do
      post "submit_answer", on: :member
    end
  end

  resources :groups, only: [:new, :create, :show, :edit, :update, :destroy] do
    member do
      get :add_members
      post :assign_members
    end
  end

  resources :students, only: [:show] # This will create a route for students#show
  
  root to: "pages#home"
end
