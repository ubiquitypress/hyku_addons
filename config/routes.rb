# frozen_string_literal: true
HykuAddons::Engine.routes.draw do
  resources :account_settings, path: "/admin/account_settings", controller: 'account_settings', as: 'admin_account_settings' do
    member do
      patch :update_single
      get :update_single
    end
  end

  get "/api/v1/tenant/:tenant_id/files/:id/work", to: "/hyku/api/v1/files#work"
end
