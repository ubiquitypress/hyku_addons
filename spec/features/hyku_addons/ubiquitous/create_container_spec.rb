# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'CRUD ubiquitous container', js: false do
  let(:user)    { create(:user) }
  let(:account) { create(:account) }

  let!(:content) { FactoryBot.create(:ubiquitous_content) }
  let(:container_attributes) { FactoryBot.attributes_for(:ubiquitous_container, content: content) }

  before do
    user.add_role(:admin, Site.instance)
    login_as(user)
    visit '/dashboard'
  end

  context "With no existing container" do
    scenario "Create a new container" do
      click_link "Widgets"
      click_link "New"
      within "#new_container" do
        fill_in("Name", with: container_attributes[:name])
        fill_in("Custom title", with: container_attributes[:custom_title])
        fill_in("Custom description", with: container_attributes[:custom_description])
        select(content.name, from: "Content")
        click_button "Save"
      end
      expect(page).to have_selector(".alert.alert-success", text: I18n.t("hyku_addons.admin.ubiquitous.containers.create.success"))

      latest_container = HykuAddons::Ubiquitous::Container.last
      expect(latest_container).to be_present
      expect(latest_container.attributes.with_indifferent_access).to include(container_attributes)
    end
  end

  context "With an existing ::Container" do
    before do
      @container = FactoryBot.create(:ubiquitous_container)
    end

    scenario "List containers" do
      click_link "Widgets"
      within "table.table" do
        within("#ubiquitous_container_#{@container.id}") do
          expect(page).to have_selector "td", text: @container.name
          expect(page).to have_selector "td", text: @container.content.name
          expect(page).to have_selector "td", text: @container.style
        end
      end
    end

    scenario "Edit a container" do
      click_link "Widgets"
      within "table.table #ubiquitous_container_#{@container.id}" do
        first('td.table-actions a').click
      end

      within "#edit_container" do
        fill_in("Name", with: container_attributes[:name])
        fill_in("Custom title", with: container_attributes[:custom_title])
        fill_in("Custom description", with: container_attributes[:custom_description])
        select(content.name, from: "Content")
        click_button "Save changes"
      end

      expect(page).to have_selector(".alert.alert-success", text: I18n.t("hyku_addons.admin.ubiquitous.containers.update.success"))

      expect(@container.attributes.with_indifferent_access).to include(container_attributes)
    end

    scenario "Delete a container" do
      click_link "Widgets"
      within "table.table #ubiquitous_container_#{@container.id}" do
        find('a.destroy-action').click
      end
      expect(page).to have_selector(".alert.alert-success", text: I18n.t("hyku_addons.admin.ubiquitous.containers.destroy.success"))
      expect { @container.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
