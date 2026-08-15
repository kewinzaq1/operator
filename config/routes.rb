Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "health" => "health#show"

  root "pages#home"
  get "dashboard", to: "dashboard#show"
  post "agent_runs", to: "agent_runs#create"
  post "demo/reset", to: "demo#reset", as: :demo_reset
  patch "approvals/:id", to: "approvals#update", as: :approval

  get "payments/success", to: "payments#success"
  get "payments/cancel", to: "payments#cancel"

  namespace :webhooks do
    post :stripe, to: "stripe#create"
    post :linq, to: "linq#create"
    post :whop, to: "whop#create"
  end
end
