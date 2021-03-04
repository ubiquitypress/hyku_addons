# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::SimplifiedAdminSetSelectionWorkFormHelper do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:model_class) do
    Class.new(GenericWork) do
      include ::HykuAddons::GenericWorkOverrides
    end
  end
  let(:work) { model_class.new(title: ["Moomin"], depositor: user.user_key) }
  let(:form_class) do
    Class.new(Hyrax::GenericWorkForm) do
      include ::HykuAddons::GenericWorkFormOverrides
    end
  end
  let(:form) { form_class.new(work, nil, nil) }
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
        expect(helper).to receive(:can_edit?).with(form.model).and_return(true)
        expect(helper).to receive(:depositor?).with(form.depositor).and_return(true)
      end

      it "includes relationships" do
        expect(helper.form_tabs_for(form: form)).not_to include("relationships")
      end
    end
  end

  describe "#available_admin_sets" do
    it "returns an array" do
      expect(helper.available_admin_sets).to be_an(Array)
    end
  end

  describe "#can_edit?" do
    before do
      # We need to signin the user so that `current_user` is accessible to us
      sign_in(user)
    end

    it "calls current_ability" do
      expect(helper.current_ability).to receive(:can?).with(:edit, form.model)
      helper.can_edit?(form.model)
    end
  end

  describe "#depositor?" do
    context "when the depositor is signed in" do
      before do
        sign_in(user)
      end

      it "calls user_key on current_user" do
        expect(helper.current_user).to receive(:user_key)
        helper.depositor?(form.depositor)
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
