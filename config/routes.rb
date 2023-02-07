# frozen_string_literal: true

require "sidekiq/web"

HykuAddons::Engine.routes.draw do
  resources :account_settings, path: "/admin/account_settings", controller: "account_settings", as: "admin_account_settings" do
    member do
      patch :update_single
      get :update_single
    end
  end

  get "/api/v1/tenant/:tenant_id/users/:email",
      to: "/hyku/api/v1/users#show",
      param: :email,
      constraints: { email: /.*/ },
      defaults: { format: :json }

  get "/api/v1/tenant/:tenant_id/files/:id/work", to: "/hyku/api/v1/files#work"
  get "/api/v1/tenant/:tenant_id/files/:id/download", to: "/hyku/api/v1/files#download"

  get "/sso/login", to: "/hyku_addons/sso#auth", as: :sso_login
  get "sso/callback", to: "/hyku_addons/sso#callback", as: :sso_callback

  get "/importers/:id/validation", to: "/hyku_addons/importer_validations#show", as: :importer_validation

  get "/pdf_viewer(/:download_id)", to: "/hyku_addons/pdf_viewer#pdf", as: :pdf_viewer

  get "/admin/reports", to: "/hyrax/stats#reports", as: :admin_stats_report

  authenticate :user, ->(u) { u.roles_name.include? "admin" } do
    mount Sidekiq::Web => "/sidekiq"
  end
end
