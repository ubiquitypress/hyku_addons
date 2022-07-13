# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::HyraxEmbargoActorOverride do
  let(:past_date) { 1.day.ago }
  let(:future_date) { 1.day.from_now }

  let(:account) { create(:account) }

  let!(:work_with_expired_embargo) do
    build(:work, embargo_release_date: past_date.to_s,
                 visibility_during_embargo: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED,
                 visibility_after_embargo: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC).tap do |work|
      work.save(validate: false)
    end
  end

  let(:embargo_actor) { Hyrax::Actors::EmbargoActor.new(work_with_expired_embargo) }

  it "work should have correct visibility after embargo expiration" do
    embargo_actor.destroy
    expect(work_with_expired_embargo.reload.embargo_release_date).to be_nil
    expect(work_with_expired_embargo.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end
end
