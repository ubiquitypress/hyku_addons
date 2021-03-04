# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::SimplifiedAdminSetSelectionWorkFormHelper do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:work) { GenericWork.new(title: ["Moomin"], depositor: user.user_key) }
  let(:form) { Hyrax::GenericWorkForm.new(work, nil, nil) }
  let(:helper) { _view }

  describe "#form_tabs_for" do
    context "when the feature is disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(false)
      end

      it "includes relationships" do
        expect(helper.form_tabs_for(form: form)).to include("relationships")
      end
    end

    context "when the feature is enabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(true)
        allow(helper).to receive(:can_edit?).with(form.model).and_return(true)
        allow(helper).to receive(:depositor?).with(form.depositor).and_return(true)
      end

      it "includes relationships" do
        expect(helper.form_tabs_for(form: form)).not_to include("relationships")
      end
    end

    context "when the user can edit the work but is not the depositor" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(true)
        allow(helper).to receive(:can_edit?).with(form.model).and_return(true)
        allow(helper).to receive(:depositor?).with(form.depositor).and_return(false)
      end

      it "includes relationships" do
        expect(helper.form_tabs_for(form: form)).to include("relationships")
      end
    end
  end

  describe "#available_admin_sets" do
    it "returns an array" do
      expect(helper.available_admin_sets).to be_an(Array)
    end
  end

  describe "#depositor?" do
    context "when the depositor is signed in" do
      before do
        sign_in(user)
      end

      it "is true" do
        expect(helper.depositor?(form.depositor)).to be_truthy
      end
    end

    context "when the depositor is not signed in" do
      let(:admin) { create(:admin) }

      before do
        sign_in(admin)
      end

      it "is false" do
        expect(helper.depositor?(form.depositor)).to be_falsey
      end
    end
  end
end
