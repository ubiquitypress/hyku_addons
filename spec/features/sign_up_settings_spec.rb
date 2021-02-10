# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Sign Up", type: :feature do
  let(:account) { FactoryBot.create(:account) }

  before do
    Site.update(account: account)
  end

  context 'with account signup enabled' do
    it "allows the user to create an account with a valid email format" do
      visit '/users/sign_up'
      fill_in 'user_display_name', with: "Test User"
      fill_in 'user_email', with: "test@test.com"
      fill_in 'user_password', with: "Potato123!"
      fill_in 'user_password_confirmation', with: "Potato123!"
      expect { click_on 'Create account' }.to change { User.count }.by(1)
    end

    it "prevents users from creating an account without the correct email formats" do
      visit '/users/sign_up'
      fill_in 'user_display_name', with: "Test User"
      fill_in 'user_email', with: "test@badformat.com"
      fill_in 'user_password', with: "Potato123!"
      fill_in 'user_password_confirmation', with: "Potato123!"
      expect { click_on 'Create account' }.to change { User.count }.by(0)
      expect(page).to have_content('Email must contain @pacificu.edu, @ubiquitypress.com, @test.com')
    end
  end

  context 'with account signup diabled' do
    it 'does not allow a user to create an account' do
      account.allow_signup = "false"
      account.save!
      visit '/users/sign_up'
      expect(page).to have_content("Account registration is disabled")
    end
  end

  context 'default value' do
    it 'defaults to true' do
      byebug
      expect(Account.new.allow_signup).to eq "true"
    end
  end
end
