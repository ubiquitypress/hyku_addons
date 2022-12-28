# frozen_string_literal: true
require "rails_helper"

RSpec.feature HykuAddons::WorkForm do
  let(:form) { form_class.new(work, nil, nil) }
  let(:form_class) { Hyrax::GenericWorkForm }
  let(:work) { GenericWork.new }

  describe "#primary_terms" do
    subject { form.primary_terms }

    it { is_expected.not_to include :admin_set_id }

    context "with simplified_admin_set_selection enabled" do
      before do
        allow(Flipflop).to receive(:enabled?).and_call_original
        allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(true)
      end

      it { is_expected.to include :admin_set_id }
    end

    context "with RedlandsArticle" do
      let(:form_class) { Hyrax::RedlandsArticleForm }
      let(:work) { RedlandsArticle.new }

      it { is_expected.not_to include :admin_set_id }

      context "with simplified_admin_set_selection enabled" do
        before do
          allow(Flipflop).to receive(:enabled?).and_call_original
          allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(true)
        end

        it { is_expected.to include :admin_set_id }
      end
    end
  end

  describe "doi settings options" do
    let(:user) { create(:user, invitation_accepted_at: DateTime.now.utc) }
    let(:admin) { create(:admin, invitation_accepted_at: DateTime.now.utc) }
    let(:work_type) { "ubiquity_template_work" }
    let(:new_work_path) { "concern/#{work_type.to_s.pluralize}/new" }

    before do
      allow(Flipflop).to receive(:enabled?).and_call_original
      allow(Flipflop).to receive(:enabled?).with(:doi_minting).and_return(true)
    end

    context "is not hidden" do
      before do
        login_as admin
      end

      it "for admins" do
        visit new_work_path
        expect(page).to have_content(/Create draft DOI/)
        expect(page).to have_content(/DOI status when work is public/)
      end
    end

    context "is hidden" do
      before do
        login_as user
        flipflop_strategy = Flipflop::FeatureSet.current.test!
        flipflop_strategy.switch!(:hide_doi_options, true)
      end

      it "for normal users" do
        visit new_work_path
        expect(page).not_to have_content(/Create draft DOI/)
        expect(page).not_to have_content(/DOI status when work is public/)
      end
    end

    context "when Flipflop :hide_doi_options is disabled" do
      before do
        login_as user
        flipflop_strategy = Flipflop::FeatureSet.current.test!
        flipflop_strategy.switch!(:hide_doi_options, false)
      end

      it "is not hidden for normal users" do
        visit new_work_path
        expect(page).to have_content(/Create draft DOI/)
        expect(page).to have_content(/DOI status when work is public/)
      end
    end
  end

  describe "Check that Sherpa romeo text does not appear" do
    let(:admin) { create(:admin, invitation_accepted_at: DateTime.now.utc) }
    let(:work_type) { "ubiquity_template_work" }
    let(:new_work_path) { "concern/#{work_type.to_s.pluralize}/new" }

    before do
      login_as admin
    end

    it "when visibiity option open is selected" do
      visit new_work_path
      choose("ubiquity_template_work[visibility]", option: "open")
      expect(page).not_to have_content(/SHERPA\/RoMEO/)
    end
  end
end
