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

  describe "#display_profile" do
    it "defaults to false" do
      expect(user.display_profile).to eq false
    end
  end

  describe "#display_profile_visibility" do
    context "when display_profile is true" do
      it "returns a string 'open'" do
        user.display_profile = true

        expect(user.display_profile_visibility).to be_a(String)
        expect(user.display_profile_visibility).to eq(User::PROFILE_VISIBILITY[:open])
      end
    end

    context "when display_profile is false" do
      it "returns a string 'closed'" do
        user.display_profile = false

        expect(user.display_profile_visibility).to be_a(String)
        expect(user.display_profile_visibility).to eq(User::PROFILE_VISIBILITY[:closed])
      end
    end
  end
end
