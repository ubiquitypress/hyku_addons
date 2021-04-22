# frozen_string_literal: true

require 'spec_helper'

RSpec.describe User, type: :model do
  subject(:user) { FactoryBot.create(:base_user) }

  it { is_expected.to have_one(:orcid_identity) }

  describe "#orcid_identity?" do
    context "when the user has not authorized with ORCID" do
      it "is false" do
        expect(user.orcid_identity?).to be_falsey
      end
    end

    context "when the association is found on the user" do
      subject(:user) { FactoryBot.create(:base_user, :with_orcid_identity) }

      it "is true" do
        expect(user.orcid_identity?).to be_truthy
      end
    end
  end
end
