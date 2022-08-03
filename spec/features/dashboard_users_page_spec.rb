# frozen_string_literal: true

RSpec.feature "Dashboard Users Page", type: :feature do
  let(:user) { create(:user, email: "abc@test.com") }

  context "User Index page" do
    before do
      login_as user
    end

    it "contains link_to edit profile" do
      visit "/admin/users?locale=en"

      expect(page).to have_text(user.email)
      expect(page).to have_link(user.email)
    end
  end
end
