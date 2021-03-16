# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::SimplifiedDepositFormHelper do
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
  end

  describe "#form_tabs_for" do
    context "when the feature is disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:simplified_deposit_form).and_return(false)
      end

      it "includes doi" do
        expect(helper.form_tabs_for(form: form)).to include("doi")
      end
    end

    context "when the feature is enabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:simplified_deposit_form).and_return(true)
      end

      describe "when the user is not an admin" do
        before do
          allow(helper).to receive(:applicable?).with(form.model).and_return(true)
        end

        it "includes doi" do
          expect(helper.form_tabs_for(form: form)).not_to include("doi")
        end
      end

      describe "when the user is an admin" do
        before do
          allow(helper).to receive(:applicable?).with(form.model).and_return(false)
        end

        it "includes doi" do
          expect(helper.form_tabs_for(form: form)).to include("doi")
        end
      end
    end
  end
end

