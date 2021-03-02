# frozen_string_literal: true

require "rails_helper"

RSpec.describe "HykuAddons::RevisedAdminSetWorkFormHelper" do
  describe "form_tabs_for" do
    let(:work) { GenericWork.new(title: ["Moomin"]) }
    let(:form) { Hyrax::GenericWorkForm.new(work, nil, nil) }
    let(:helper) do
      _view.tab do |v|
        v.extend(ApplicationHelper)
        v.extend(HyraxHelper)
        v.extend(Hyrax::DOI::WorkFormHelper)
        v.assign(view_assigns)
      end
    end
    let(:feature_name) { :simplified_admin_set_selection }

    describe "when the feature is disabled" do
      before do
        Flipflop::FeatureSet.current.replace do
          Flipflop.configure do
            feature feature_name, default: false
          end
        end
      end

      it "includes relationships" do

      end
    end

    describe "when the feature is enabled" do
      before do
        Flipflop::FeatureSet.current.replace do
          Flipflop.configure do
            feature feature_name default: true
          end
        end
      end

    end
  end
end
