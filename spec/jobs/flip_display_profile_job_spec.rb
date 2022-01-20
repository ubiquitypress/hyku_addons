# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::FlipDisplayProfileJob, type: :job do
  let(:user) { create(:user, email: "test@example.com") }
  let(:creator) do
    [
      { creator_family_name: "Hawking", creator_given_name: "Stephen", creator_organization_name: "",
        creator_institutional_email: user.email, display_creator_profile: user.display_profile }
    ].to_json
  end
  let(:work) { create(:work, creator: [creator]) }

  it "is enqueued when a user changes their display_profile setting" do
    user.display_profile = true
    expect { user.save }.to have_enqueued_job(HykuAddons::FlipDisplayProfileJob)
  end

  it "does not enque a job unless the display profile setting has been changed" do
    user.department = "software development"
    expect { user.save }.not_to have_enqueued_job(HykuAddons::FlipDisplayProfileJob)
  end

  it "changes the display profile field for the works where the user is the creator" do
    user.display_profile = !user.display_profile
    user.save
    perform_enqueued_jobs(only: HykuAddons::FlipDisplayProfileJob) do
      HykuAddons::FlipDisplayProfileJob.perform_now(user2.email, user2.display_profile)
    end
    expect(JSON.parse(work["creator"].first).first["display_creator_profile"]).to eq(user.display_profile)
  end
end
