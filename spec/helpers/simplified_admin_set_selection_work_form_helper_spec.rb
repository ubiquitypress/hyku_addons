# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::SimplifiedAdminSetSelectionWorkFormHelper do
  let(:model_class) do
    Class.new(GenericWork) do
      include ::HykuAddons::GenericWorkOverrides
    end
  end
  let(:work) { model_class.new(title: ["Moomin"]) }
  let(:form_class) do
    Class.new(Hyrax::GenericWorkForm) do
      include ::HykuAddons::GenericWorkFormOverrides
    end
  end
  let(:form) { form_class.new(work, nil, nil) }
  let(:helper) { _view }

  describe "form_tabs_for" do
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
        expect(helper).to receive(:can_edit?).with(form.model).and_return(true)
        expect(helper).to receive(:depositor?).with(form.depositor).and_return(true)
      end

      it "includes relationships" do
        expect(helper.form_tabs_for(form: form)).not_to include("relationships")
      end
    end
  end
end
