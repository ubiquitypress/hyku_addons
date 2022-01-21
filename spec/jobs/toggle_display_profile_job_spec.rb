# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::ToggleDisplayProfileJob, type: :job, clean: true do
  let(:user) { create(:user) }
  let(:creator) do
    [
      {
          creator_family_name: "Hawking",
          creator_given_name: "Stephen",
          creator_organization_name: "",
          creator_institutional_email: user.email,
          display_creator_profile: user.display_profile
      }
    ].to_json
  end
  let(:work) { create(:work, creator: [creator]) }

  it "is enqueued when a user changes their display_profile setting" do
    user.display_profile = true
    expect { user.save }.to have_enqueued_job(HykuAddons::ToggleDisplayProfileJob)
  end

  it "does not enque a job unless the display profile setting has been changed" do
    user.department = "software development"
    expect { user.save }.not_to have_enqueued_job(HykuAddons::ToggleDisplayProfileJob)
  end

  it "changes the display profile field for the works where the user is the creator" do
    expect{ HykuAddons::ToggleDisplayProfileJob.perform_now(user.email, !user.display_profile) }.to change { JSON.parse(work.reload["creator"].first).first["display_creator_profile"] }
  end
end
