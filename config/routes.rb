# frozen_string_literal: true
HykuAddons::Engine.routes.draw do
  resources :account_settings, path: "/admin/account_settings", controller: 'account_settings', as: 'admin_account_settings' do
    member do
      patch :update_single
      get :update_single
    end
  end
  get "/concern/parent/:parent_id/file_sets/:id/download", to: "/hyrax/file_sets#download", as: "file_set_download"
end
