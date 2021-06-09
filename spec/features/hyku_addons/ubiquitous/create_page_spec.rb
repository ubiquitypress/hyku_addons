# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create a ubiquitous page', js: false do
  let(:user)    { create(:user) }
  let(:account) { create(:account) }

  let(:page_attributes) { FactoryBot.attributes_for(:ubiquitous_page) }

  before do
    HykuAddons::Ubiquitous::Page.table_name =  "hyku_addons_ubiquitous_pages"
    HykuAddons::Ubiquitous::Widget.table_name =  "hyku_addons_ubiquitous_widgets"
    user.add_role(:admin, Site.instance)
    login_as(user)
    visit '/dashboard'
  end

  scenario "Create a new page" do
    click_link "Customised Pages"
    click_link "New"
    within "#new_page" do
      fill_in("Name", with: page_attributes[:name])
      fill_in("Path matcher", with: page_attributes[:path_matcher])
      click_button "Save"
    end
    expect(page).to have_selector(".alert.alert-success", text: I18n.t("hyku_addons.admin.ubiquitous.pages.create.success"))

    latest_page = HykuAddons::Ubiquitous::Page.last
    expect(latest_page).to be_present
    expect(latest_page.attributes.with_indifferent_access).to include(page_attributes)
  end

  context "With an existing ::Page" do
    before do
      @page = FactoryBot.create(:ubiquitous_page)
    end

    scenario "List pages" do
      click_link "Customised Pages"
      within "table.table" do
        within("#page_#{@page.id}") do
          expect(page).to have_selector "td", text: @page.name
          expect(page).to have_selector "td", text: @page.hyku_widgets.count
          expect(page).to have_selector "td", text: @page.updated_at
        end
      end
    end

    scenario "Edit a page" do
      click_link "Customised Pages"
      within "table.table #page_#{@page.id}" do
        first('td.table-actions a').click
      end

      within "#edit_page" do
        fill_in("Name", with: "Foo")
        fill_in("Path matcher", with: "Bar")
        click_button "Save changes"
      end

      expect(page).to have_selector(".alert.alert-success", text: I18n.t("hyku_addons.admin.ubiquitous.pages.update.success"))

      expect(@page.reload.attributes.with_indifferent_access).to include(name: "Foo", path_matcher: "Bar")
    end

    scenario "Delete a page" do
      click_link "Customised Pages"
      within "table.table #page_#{@page.id}" do
        find('a.destroy-action').click
      end
      expect(page).to have_selector(".alert.alert-success", text: I18n.t("hyku_addons.admin.ubiquitous.pages.destroy.success"))
      expect { @page.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
