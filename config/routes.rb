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

  scope :dashboard do
    resources :orcid_identity, only: %i[new update destroy], controller: "/hyrax/dashboard/orcid/orcid_identities"
    get "orcid_works/approve/:orcid_id/:work_id", to: "/hyrax/dashboard/orcid/works#approve", as: :orcid_works_approval
  end

  get "/importers/:id/validation", to: "/hyku_addons/importer_validations#show", as: :importer_validation
end
