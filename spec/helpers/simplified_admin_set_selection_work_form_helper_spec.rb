# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::SimplifiedAdminSetSelectionWorkFormHelper do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:work) { GenericWork.new(title: ["Moomin"], depositor: user.user_key) }
  let(:form) { Hyrax::GenericWorkForm.new(work, nil, nil) }
  let(:helper) { _view }

  before do
    # NOTE:
    # This seems to be required or the following error is received:
    # Please stub a default value first if message might be received with other args as well.
    allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(false)
    allow(Flipflop).to receive(:enabled?).with(:simplified_deposit_form).and_return(false)

    allow(controller).to receive(:current_user) { user }
  end

  describe "#form_tabs_for" do
    context "when the user is an admin and the feature is enabled" do
      before do
        user.add_role(:admin, Site.instance)

        allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(true)
      end

      it "shows the tab" do
        expect(helper.form_tabs_for(form: form)).to include("relationships")
      end
    end

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
        allow(helper).to receive(:permission?).with(form.model).and_return(true)
        allow(helper).to receive(:depositor?).with(form.depositor).and_return(true)
      end

      it "includes relationships" do
        expect(helper.form_tabs_for(form: form)).not_to include("relationships")
      end
    end

    context "when the user can edit the work but is not the depositor" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(true)
        allow(helper).to receive(:permission?).with(form.model).and_return(true)
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
      it "is true" do
        expect(helper.depositor?(form.depositor)).to be_truthy
      end
    end

    context "when the depositor is not signed in" do
      let(:admin) { create(:admin) }

      before do
        allow(controller).to receive(:current_user) { admin }
      end

      it "is false" do
        expect(helper.depositor?(form.depositor)).to be_falsey
      end
    end
  end
end
