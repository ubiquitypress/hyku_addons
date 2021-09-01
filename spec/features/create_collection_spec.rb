# frozen_string_literal: true
require 'rails_helper'

include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a Collection', js: false, clean: true do
  let(:user) { FactoryBot.create(:admin) }
  let(:collection_type) { Hyrax::CollectionType.create(title: 'test_collection_type') }

  before do
    allow(Flipflop).to receive(:enabled?).and_return(false)
    collection_type
    login_as user
  end

  it 'creates a collection without creator or contributor' do
    visit '/dashboard'
    click_link "Collections"
    click_link "New Collection"

    # Title
    fill_in('Title', with: 'My Test Collection')

    click_button 'Save'

    visit page.current_path.sub('/edit', '')

    expect(page).to have_content('My Test Collection')
    expect(page).not_to have_content('Creator')
    expect(page).not_to have_content('Contributor')
  end

  it 'creates a collection with creator' do
    visit '/dashboard'
    click_link "Collections"
    click_link "New Collection"

    # Title
    fill_in('Title', with: 'My Test Collection')

    # Creator
    select('Personal', from: 'collection_creator__creator_name_type')
    fill_in('collection_creator__creator_family_name', with: 'Hawking')
    fill_in('collection_creator__creator_given_name', with: 'Stephen')
    fill_in('collection_creator__creator_orcid', with: '0000-0002-9079-593X')
    select('Staff member', from: 'collection_creator__creator_institutional_relationship')
    fill_in('collection_creator__creator_isni', with: '0000 0001 2103 4996')

    click_button 'Save'

    visit page.current_path.sub('/edit', '')

    # Title
    expect(page).to have_content('My Test Collection')

    # Creator
    expect(page).to have_content('Hawking, Stephen')
    expect(page).to have_link('', href: 'https://orcid.org/000000029079593X')
    expect(page).to have_link('', href: 'https://isni.org/isni/0000000121034996')

    expect(page).not_to have_content('Contributor')
  end

  context "when user is not an admin" do
    let(:user) { FactoryBot.create(:user) }
    it "Does not display the collections link when the setting is off" do
      allow(Flipflop).to receive(:enabled?).with(:show_repository_objects_links).and_return(false)

      visit '/dashboard'
      expect(page).not_to have_link("Collections")
    end

    it "Does display the collections link when the setting is on" do
      allow(Flipflop).to receive(:enabled?).with(:show_repository_objects_links).and_return(true)
      visit '/dashboard'
      expect(page).to have_link("Collections")
    end
  end
  context "when user is an admin" do
    it "Displays the collections link when the setting is off" do
      allow(Flipflop).to receive(:enabled?).with(:show_repository_objects_links).and_return(false)
      visit '/dashboard'
      expect(page).to have_link("Collections")
    end

    it "Does display the collections link when the setting is on" do
      allow(Flipflop).to receive(:enabled?).with(:show_repository_objects_links).and_return(true)
      visit '/dashboard'
      expect(page).to have_link("Collections")
    end
  end
end
