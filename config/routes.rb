# frozen_string_literal: true
HykuAddons::Engine.routes.draw do
  resources :account_settings, path: "/admin/account_settings", controller: 'account_settings', as: 'admin_account_settings' do
    member do
      patch :update_single
      get :update_single
    end
  end

  namespace :admin do
    namespace :ubiquitous do
      resources :widgets, controller: 'containers', as: :containers
      resources :pages do
        resources :hyku_widgets, as: :ubiquitous_hyku_widgets
      end
    end
  end

  get "/api/v1/tenant/:tenant_id/files/:id/work", to: "/hyku/api/v1/files#work"
  get "/api/v1/tenant/:tenant_id/files/:id/download", to: "/hyku/api/v1/files#download"

  get "/importers/:id/validation", to: "/hyku_addons/importer_validations#show", as: :importer_validation
end
