# frozen_string_literal: true

HykuAddons::Engine.routes.draw do
  resources :account_settings, path: "/admin/account_settings", controller: 'account_settings', as: 'admin_account_settings' do
    member do
      patch :update_single
      get :update_single
    end
  end

  get "/api/v1/tenant/:tenant_id/files/:id/work", to: "/hyku/api/v1/files#work"
  get "/api/v1/tenant/:tenant_id/files/:id/download", to: "/hyku/api/v1/files#download"

  get "/importers/:id/validation", to: "/hyku_addons/importer_validations#show", as: :importer_validation
  get "/concern/parent/:parent_id/file_sets/:file_set_id/proxy", to: "/hyku_addons/pdf_viewer#proxy"
  get "/concern/parent/:parent_id/file_sets/:file_set_id/pdf", to: "/hyku_addons/pdf_viewer#pdf"
end
