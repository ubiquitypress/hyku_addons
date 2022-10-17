# frozen_string_literl: true
require "rails_helper"

RSpec.feature HykuAddons::WorkForm do
  let(:form) { form_class.new(work, nil, nil) }
  let(:form_class) { Hyrax::LtuSerialForm }
  let(:work) { LtuSerial.new }

  describe "Worktype language localisations" do
    let(:user) { create(:user, invitation_accepted_at: DateTime.now.utc) }
    let(:admin) { create(:admin, invitation_accepted_at: DateTime.now.utc) }
    let(:work_type) { "ltu_serial" }
    let(:new_work_path) { "concern/#{work_type.to_s.pluralize}/new" }

    context "Check spelling" do
      before do
        login_as admin
        puts new_work_path
        visit new_work_path
      end

      after do
        page.save_page("/home/app/wip.html")
      end

      it "Creator name type organisational should be “organizational" do
        dropdown = find("#ltu_serial_creator__creator_name_type")
        options = dropdown.all("option").map{|n| n.value}
        expect(options).to include("Organizational")
      end

      it "Creator organisation name should be Creator organization name" do
        expect(page).to have_content(/Creator organization name/)
      end

      it "Creator organization name is Creator organization name" do
        expect(page).to have_content(/Creator organization name/)
      end

      it "organisation's name in description text for Creator organization name should read organization's name" do
        expect(page).to have_content(/Creator organization's name/)
      end

      it "organisation's name in description text for Creator organization name should read organization's name" do
        expect(page).to have_content(/Creator organization's name/)
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

      it "Licence should be License" do
        expect(page).to have_content(/License/)
      end

      it "Organisational unit should be Organizational unit" do
        expect(page).to have_content(/Organizational unit/)
      end

      it "Organisational structure in descriptive text for Organizational unit should be organizational structure" do
        expect(page).to have_content(/organizational structure/)
      end

      it "Contributor name type>> organisational should be organizational" do
        expect(page).to have_content(/organizational structure/)
      end

      it 'Contributor organisation name should be Contributor organization name' do
        expect(page).to have_content(/Contributor organization name/)
      end

      it 'Contributor organisation name should be Contributor organization name' do
        expect(page).to have_content(/Contributor organization name/)
      end

      it "organisation's name in help text for Contributor organization name should read organization's name" do
        expect(page).to have_content(/organization's name/)
      end


      it 'Creator organisation ROR should be Contributor organization ROR' do
        expect(page).to have_content(/Contributor organization ROR/)
      end

      it 'Creator organisation GRID should be Contributor organization GRID' do
        expect(page).to have_content(/Contributor organization GRID/)
      end

      it "Creator organisation Wikidata should be Contributor organization Wikidata" do
        expect(page).to have_content(/Contributor organization Wikidata/)
      end

      it "Creator organisation Wikidata should be Contributor organization Wikidata" do
        expect(page).to have_content(/Contributor organization Wikidata/)
      end

    end
  end
end
