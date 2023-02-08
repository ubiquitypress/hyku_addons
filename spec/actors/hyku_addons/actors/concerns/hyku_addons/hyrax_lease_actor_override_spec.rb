# frozen_string_literal: true
require "rails_helper"
# TODO: flaky tests. Need fixing.
RSpec.xdescribe HykuAddons::HyraxLeaseActorOverride do
  let(:past_date) { 1.day.ago }
  let(:future_date) { 1.day.from_now }

  let(:account) { create(:account) }

  let!(:work_with_expired_lease) do
    build(:work, lease_expiration_date: past_date.to_s,
                 visibility_during_lease: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
                 visibility_after_lease: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED).tap do |work|
      work.save(validate: false)
    end
  end

  let(:lease_actor) { Hyrax::Actors::LeaseActor.new(work_with_expired_lease) }

  it "work should have correct visibility after lease expiration" do
    lease_actor.destroy
    expect(work_with_expired_lease.reload.lease_expiration_date).to be_nil
    expect(work_with_expired_lease.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
  end
end
