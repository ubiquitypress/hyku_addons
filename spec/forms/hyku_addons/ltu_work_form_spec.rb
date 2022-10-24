# frozen_string_literal: true
require "rails_helper"

RSpec.feature HykuAddons::WorkForm do
  let(:form) { form_class.new(work, nil, nil) }
  let(:form_class) { Hyrax::LtuSerialForm }
  let(:work) { LtuSerial.new }
  let(:options) { { locale: :en, tenant: "LTU" } }

  describe "Worktype language localisations" do
    let(:user) { create(:user, invitation_accepted_at: DateTime.now.utc) }
    let(:admin) { create(:admin, invitation_accepted_at: DateTime.now.utc) }
    let(:work_type) { "ltu_serial" }
    let(:new_work_path) { "concern/#{work_type.to_s.pluralize}/new?locale=en-LTU" }

    context "Check spelling" do
      before do
        HykuAddons::I18nMultitenant.set(locale: "en", tenant: "LTU")
        login_as admin
        visit new_work_path
        click_on "Additional fields"
      end

      it "Creator name type organisational should be 'organizational' " do
        dropdown = find("#ltu_serial_creator__creator_name_type")
        options = dropdown.all("option").map(&:value)
        expect(options).to include("Organizational")
      end

      it "Creator organisation name should be Creator organization name" do
        expect(page).to have_content(/Creator organization name/)
      end

      it "organisation spelling in description text for Creator organization should be organization" do
        expect(page).to have_content(/Please enter the organization's name/)
      end

      it "Creator organisation ROR should be “Creator organization ROR" do
        expect(page).to have_content(/Creator organization ROR/)
      end

      it "Creator organisation GRID should be Creator organization GRID" do
        expect(page).to have_content(/Creator organization GRID/)
      end

      it "Creator organisation Wikidata should be Creator organization Wikidata" do
        expect(page).to have_content(/Creator organization Wikidata/)
      end

      xit "Licence should be License" do
        expect(page).to have_content(/License/)
      end

      it "Organisational unit should be Organizational unit" do
        expect(page).to have_content(/Organizational unit/)
      end

      it "Organisational structure in descriptive text for Organizational unit should be organizational structure" do
        expect(page).to have_content(/organizational structure/)
      end

      it "contributor_name_type label should be organizational" do
        expect(page).to have_content(/organizational/)
      end

      it "organisation name should be spelt as Contributor organization name" do
        expect(page).to have_content(/Contributor organization name/)
      end

      it "display organisation spelling in help text for Contributor should be  organization" do
        expect(page).to have_content(/organization's name/)
      end

      it "Contributor organisation ROR should be Contributor organization ROR" do
        expect(page).to have_content(/Contributor organization ROR/)
      end

      it "Contributor organisation GRID should be Contributor organization GRID" do
        expect(page).to have_content(/Contributor organization GRID/)
      end

      it "Contributor organisation Wikidata should be Contributor organization Wikidata" do
        expect(page).to have_content(/Contributor organization Wikidata/)
      end
    end
  end
end
