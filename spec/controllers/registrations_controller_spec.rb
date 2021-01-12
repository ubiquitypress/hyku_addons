# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HykuAddons::RegistrationsController, type: :feature do
  let(:account) { FactoryBot.create(:account) }

  context 'with account signup enabled' do
    it "allows the user to create an account" do
      account.settings['allow_signup'] = "true"
      account.save!
      account.reload
      visit '/users/sign_up'
      fill_in 'Your Name', with: "Test User"
      fill_in 'Email address', with: "test@test.com"
      fill_in 'user_password', with: "Potato123!"
      fill_in 'user_password_confirmation', with: "Potato123!"
      expect{ click_on 'Create account' }.to change{ User.count }.by(1)
      expect(page).to have_content("Create a new account")
    end
  end

  context 'with account signup diabled' do
    it 'does not allow a user to create an account' do
      account.settings['allow_signup'] = "false"
      account.save!
      account.reload
      visit '/users/sign_up'
      expect(page).to have_content("Account registration is disabled")
    end
  end
end
