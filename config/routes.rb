Rails.application.routes.draw do
  # devise_for :users
  devise_for :users, controllers: { registrations: "users/registrations" }

  # Dashboard routes
  get "dashboard", to: "dashboards#index", as: "dashboard"
  get "dashboard/leerlingenlijsten", to: "dashboards#my_groups", as: "dashboard_my_groups"
  get "dashboard/manage_users", to: "dashboards#manage_users", as: "dashboard_manage_users"
  get "dashboard/manage_users/:id/edit", to: "dashboards#edit_user_profile", as: "dashboard_edit_user_profile"
  get "dashboard/subscriptions", to: "dashboards#subscriptions", as: "dashboard_subscriptions"
  get "dashboard/logboek", to: "dashboards#logbook", as: "dashboard_logbook"
  patch "dashboard/manage_users/:id", to: "dashboards#update_user_profile", as: "dashboard_update_user_profile"
  patch "dashboard/manage_users/:id/approve", to: "dashboards#approve_user", as: "dashboard_approve_user"
  delete "dashboard/manage_users/:id", to: "dashboards#destroy_user", as: "dashboard_delete_user"
  # post "register_for_course", to: "dashboards#register_for_course", as: "register_for_course"

  # Courses routes
  resources :courses, only: [:new, :create, :index, :edit, :update, :destroy] do
    collection do
      get :my_courses
      get :weekly_task              # Route for viewing the "Create Weekly Task" form
      post :create_weekly_task      # Route for creating a new Weekly Task
    end

    member do
      get :edit_weekly_task         # Route for viewing the "Edit Weekly Task" form
      patch :update_weekly_task     # Route for updating the existing Weekly Task
      delete "unenroll", to: "courses#unenroll"
    end

    resources :questions, only: [:show] do
      post "submit_answer", on: :member
    end
  end

  resources :levels, path: "niveaus"

  # Groups routes
  resources :groups, only: [:new, :create, :show, :edit, :update, :destroy] do
    member do
      get :add_members
      post :assign_members
    end
  end

  # Registrations routes
  resources :registrations, only: :create do
    patch :update_time_spent, on: :collection
  end

  # Students routes
  resources :students, only: [:index, :show]

  # Subscriptions routes
  resources :subscriptions, only: [:new, :create] do
    member do
      delete :cancel
    end
  end
  get "/subscriptions/processing", to: "subscriptions#processing", as: :processing_subscription
  get "/subscriptions/status", to: "subscriptions#status"
  get "/subscription-success", to: "subscriptions#success"
  post "/subscriptions/webhook", to: "subscriptions#webhook"
  
  # Postmark webhook
  post "/postmark/webhook", to: "postmark_webhooks#webhook"

  # Root route
  root to: "pages#home"

  require "sidekiq/web"

  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
  else
    authenticate :user, ->(u) { u.admin? } do
      mount Sidekiq::Web => "/sidekiq"
    end
  end
end
