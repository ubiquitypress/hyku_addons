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
  let(:helper) do
    _view.tap do |v|
      v.extend(ApplicationHelper)
      v.extend(HyraxHelper)
      v.extend(HykuAddons::HelperBehavior)
      v.assign(view_assigns)
    end
  end

  describe "form_tabs_for" do
    context "when the feature is disabled" do
      before do
        Flipflop::FeatureSet.current.replace do
          Flipflop.configure do
            feature :simplified_admin_set_selection, default: false
          end
        end
      end

      it "includes relationships" do
        expect(helper.form_tabs_for(form: form)).to include("relationships")
      end

      it "doesn't include admin_set_id in the form primary_terms" do
      end
    end

    context "when the feature is enabled" do
      before do
        Flipflop::FeatureSet.current.replace do
          Flipflop.configure do
            feature :simplified_admin_set_selection, default: true
          end
        end
      end

      it "includes relationships" do
        expect(helper.form_tabs_for(form: form)).not_to include("relationships")
      end
    end
  end
end
