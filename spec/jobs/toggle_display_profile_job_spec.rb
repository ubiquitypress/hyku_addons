# frozen_string_literal: true
require "rails_helper"
# TODO: flaky tests. Need fixing.
RSpec.xdescribe HykuAddons::ToggleDisplayProfileJob, type: :job, clean: true do
  let(:user) { create(:user) }
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

  it "changes the display profile field for the works where the user is the creator" do
    expect do
      HykuAddons::ToggleDisplayProfileJob.perform_now(user.email, !user.display_profile)
    end.to change { JSON.parse(work.reload["creator"].first).first["creator_profile_visibility"] }
  end
end
