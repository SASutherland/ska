Rails.application.routes.draw do
  devise_for :users

  get "dashboard", to: "dashboards#index", as: "dashboard"
  get "dashboard/groepen", to: "dashboards#my_groups", as: "dashboard_my_groups"
  get "dashboard/manage_users", to: "dashboards#manage_users", as: "dashboard_manage_users"
  get "dashboard/manage_users/:id/edit", to: "dashboards#edit_user_profile", as: "dashboard_edit_user_profile"
  patch "dashboard/manage_users/:id", to: "dashboards#update_user_profile", as: "dashboard_update_user_profile"
  delete "dashboard/manage_users/:id", to: "dashboards#destroy_user", as: "dashboard_delete_user"
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

  resources :registrations, only: [] do
    patch :update_time_spent, on: :collection
  end
  
  resources :students, only: [:index, :show]

  root to: "pages#home"
end
