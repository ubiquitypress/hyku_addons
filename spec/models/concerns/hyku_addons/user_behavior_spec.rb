# frozen_string_literal: true
RSpec.describe HykuAddons::UserBehavior, type: :model do
  subject(:user) { create(:user) }

  describe "#save" do
    let(:creator) do
      [
        {
          creator_family_name: "Hawking",
          creator_given_name: "Stephen",
          creator_organization_name: "",
          creator_institutional_email: user.email,
          creator_profile_visibility: User::PROFILE_VISIBILITY[:closed]
        }
      ].to_json
    end
    let(:work) { create(:work, creator: [creator]) }

    it "enqueues the ToggleDisplayProfileJob job when display_profile setting is updated" do
      user.display_profile = true

      expect { user.save }.to have_enqueued_job(HykuAddons::ToggleDisplayProfileJob)
    end

    it "does not enque a job unless the display profile setting has been changed" do
      user.department = "software development"

      expect { user.save }.not_to have_enqueued_job(HykuAddons::ToggleDisplayProfileJob)
    end
  end
end
