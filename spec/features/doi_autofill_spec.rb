# frozen_string_literal: true
require 'rails_helper'
require File.expand_path('../helpers/create_work_user_context', __dir__)

include Warden::Test::Helpers

RSpec.describe 'autofilling the form from DOI', js: true do
  include_context 'create work user context' do
    let(:work_type) { "article" }
    let(:doi) { "10.5438/4k3m-nyvg" }
    let(:headers) do
      {
        "Accept" => "text/html,application/json,application/xml;q=0.9, text/plain;q=0.8,image/png,*/*;q=0.5",
        "User-Agent" => "Mozilla/5.0 (compatible; Maremma/4.7.4; mailto:info@datacite.org)"
      }
    end
    let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.5438-4k3m-nyvg.json") }

    before do
      # First request returns the registrar to query
      stub_request(:get, "https://doi.org/ra/10.5438")
        .with(headers: headers.merge("Host" => "doi.org"))
        .to_return(status: 200, body: [{ "DOI": "10.5438", "RA": "DataCite" }].to_json, headers: {})

      # Second request returns the DOI metadata
      # NOTE: The headers are for XML, but the request returns JSON
      stub_request(:get, "https://api.datacite.org/dois/#{doi}?include=media,client")
        .with(headers: headers.merge("Host" => "api.datacite.org"))
        .to_return(status: 200, body: fixture, headers: {})
    end

    scenario do
      visit_new_work_page
      fill_in "#{work_type}_doi", with: doi

      accept_confirm do
        click_link "doi-autofill-btn"
      end

      click_on 'Descriptions'
      click_on 'Additional fields'

      # expect form fields have been filled in
      expect(page).to have_content("The following fields were auto-populated", wait: 10)
      expect(page).to have_field("#{work_type}_title", with: 'Eating your own Dog Food', wait: 10)
      expect(page).to have_field("#{work_type}_creator__creator_family_name", with: 'Fenner', wait: 10)
      expect(page).to have_field("#{work_type}_creator__creator_given_name", with: 'Martin', wait: 10)
      expect(page).to have_field("#{work_type}_abstract", with: 'Eating your own dog food is a slang term to describe that an organization '\
                                                                'should itself use the products and services it provides. For DataCite this '\
                                                                'means that we should use DOIs with appropriate metadata and strategies for '\
                                                                'long-term preservation for...', wait: 10)
      expect(page).to have_field("#{work_type}_keyword", with: 'datacite', wait: 10)
      expect(page).to have_field("#{work_type}_keyword", with: 'doi', wait: 10)
      expect(page).to have_field("#{work_type}_keyword", with: 'metadata', wait: 10)
      expect(page).to have_field("#{work_type}_publisher", with: 'DataCite', wait: 10)
    end
  end
end
