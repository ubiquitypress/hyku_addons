# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::SimplifiedDepositFormHelper, type: :helper do
  include Devise::Test::ControllerHelpers
  let(:helper) { _view }

  let(:work) { GenericWork.new(title: ["Moomin"]) }
  let(:form) { Hyrax::GenericWorkForm.new(work, nil, nil) }

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
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

      it "doesn't includes doi" do
        expect(helper.form_tabs_for(form: form)).not_to include("doi")
      end
    end
  end
end
