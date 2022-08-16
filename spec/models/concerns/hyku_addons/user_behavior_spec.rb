# frozen_string_literal: true

RSpec.describe HykuAddons::UserBehavior, type: :model do
  subject(:user) { create(:user) }

  describe "validations" do
    context "email_format" do
      let(:account) { create(:account, settings: { email_format: ["@abc.com", "@123.com"] }) }
      let(:site) { Site.new(account: account) }

      before do
        allow(Site).to receive(:instance).and_return(site)
      end

      context "when the users email address is not in the list" do
        it "is invalid" do
          expect { user.valid? }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context "when the users email address is in the list" do
        subject(:user) { create(:user, email: "test@abc.com") }

        it "is valid" do
          expect { user.valid? }.not_to raise_error
        end
      end
    end
  end

  describe ".with_public_profile" do
    subject(:query) { User.with_public_profile }
    let(:public_user) { create(:user, display_profile: true) }

    before do
      user && public_user
    end

    it "doesn't return private users" do
      expect(query).to include(public_user)
      expect(query).not_to include(user)
    end

    it "doesn't affect normal queries" do
      expect(User.all.count).to eq 2
    end
  end

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

  describe "callbacks" do
    let(:user_with_default_role) { build(:user, email: "abc@test.com", password: "abcdefgh", password_confirmation: "abcdefgh") }
    it "assigns registred as default role" do
      user_with_default_role.save
      expect(user_with_default_role.roles).to be_truthy
      expect(user_with_default_role.roles.map(&:name)).to include("registered")
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
