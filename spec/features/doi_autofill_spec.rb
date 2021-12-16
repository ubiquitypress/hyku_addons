# frozen_string_literal: true
require "rails_helper"
require File.expand_path("../support/shared_contexts/create_work_user_context", __dir__)

include Warden::Test::Helpers

RSpec.describe "autofilling the form from DOI", js: true, slow: true do
  let(:request_headers) do
    {
      "Accept" => "text/html,application/json,application/xml;q=0.9, text/plain;q=0.8,image/png,*/*;q=0.5",
      "Accept-Encoding" => "gzip,deflate",
      "User-Agent" => "Mozilla/5.0 (compatible; Maremma/4.9.6; mailto:info@datacite.org)",
      "Host" => "doi.org"
    }
  end
  let(:wait) { 5 }

  include_context "create work user context" do
    describe "an article work type using DOI 10.5438/4k3m-nyvg" do
      let(:work_type) { "article" }
      let(:doi) { "10.5438/4k3m-nyvg" }
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.5438-4k3m-nyvg.json") }

      before do
        # First request returns the registrar to query
        stub_request(:get, "https://doi.org/ra/10.5438")
          .with(headers: request_headers)
          .to_return(status: 200, body: [{ "DOI": "10.5438", "RA": "DataCite" }].to_json, headers: {})

        # Second request returns the DOI metadata
        # NOTE: The headers are for XML, but the request returns JSON; goto the URL to download the JSON response to stub
        stub_request(:get, "https://api.datacite.org/dois/#{doi}?include=media,client")
          .with(headers: request_headers.merge("Host" => "api.datacite.org"))
          .to_return(status: 200, body: fixture, headers: {})
      end

      context "when the doi tab is enabled" do
        before do
          allow(Flipflop).to receive(:enabled?).and_call_original
          allow(Flipflop).to receive(:doi_tab?).and_return(true)
        end

        scenario do
          visit_new_work_page
          fill_in "#{work_type}_doi", with: doi

          accept_confirm do
            click_link "doi-autofill-btn"
          end

          click_on "Descriptions"
          click_on "Additional fields"

          # expect form fields have been filled in
          expect(page).to have_content("The following fields were auto-populated", wait: wait)
          expect(page).to have_field("#{work_type}_title", with: "Eating your own Dog Food", wait: wait)
          expect(page).to have_field("#{work_type}_creator__creator_family_name", with: "Fenner", wait: wait)
          expect(page).to have_field("#{work_type}_creator__creator_given_name", with: "Martin", wait: wait)
          expect(page).to have_field("#{work_type}_abstract", with: "Eating your own dog food is a slang term to describe that an organization "\
                                                                    "should itself use the products and services it provides. For DataCite this "\
                                                                    "means that we should use DOIs with appropriate metadata and strategies for "\
                                                                    "long-term preservation for...", wait: wait)
          expect(page).to have_field("#{work_type}_keyword", with: "datacite", wait: wait)
          expect(page).to have_field("#{work_type}_keyword", with: "doi", wait: wait)
          expect(page).to have_field("#{work_type}_keyword", with: "metadata", wait: wait)
          expect(page).to have_field("#{work_type}_publisher", with: "DataCite", wait: wait)
        end
      end

      context "when the doi tab is disabled" do
        before do
          allow(Flipflop).to receive(:enabled?).and_call_original
          allow(Flipflop).to receive(:doi_tab?).and_return(false)
        end

        scenario do
          visit_new_work_page
          fill_in "doi-search", with: doi

          accept_confirm do
            click_link "doi-autofill-btn"
          end

          click_on "Descriptions"
          click_on "Additional fields"

          # expect form fields have been filled in
          expect(page).to have_content("The following fields were auto-populated", wait: wait)
          expect(page).to have_field("#{work_type}_title", with: "Eating your own Dog Food", wait: wait)
          expect(page).to have_field("#{work_type}_creator__creator_family_name", with: "Fenner", wait: wait)
          expect(page).to have_field("#{work_type}_creator__creator_given_name", with: "Martin", wait: wait)
          expect(page).to have_field("#{work_type}_abstract", with: "Eating your own dog food is a slang term to describe that an organization "\
                                                                    "should itself use the products and services it provides. For DataCite this "\
                                                                    "means that we should use DOIs with appropriate metadata and strategies for "\
                                                                    "long-term preservation for...", wait: wait)
          expect(page).to have_field("#{work_type}_keyword", with: "datacite", wait: wait)
          expect(page).to have_field("#{work_type}_keyword", with: "doi", wait: wait)
          expect(page).to have_field("#{work_type}_keyword", with: "metadata", wait: wait)
          expect(page).to have_field("#{work_type}_publisher", with: "DataCite", wait: wait)
        end
      end
    end

    describe "an anschutz_work work type using DOI 10.47989/irpaper872" do
      let(:work_type) { "anschutz_work" }
      let(:doi) { "10.47989/irpaper872" }
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.47989-irpaper872.xml") }

      before do
        # First request returns the registrar to query
        stub_request(:get, "https://doi.org/ra/10.47989")
          .with(headers: request_headers.merge("Host" => "doi.org"))
          .to_return(status: 200, body: [{ "DOI": "10.47989", "RA": "Crossref" }].to_json, headers: {})

        # # Second request returns the DOI metadata
        # # NOTE: The headers are for XML, but the request returns JSON; goto the URL to download the JSON response to stub
        stub_request(:get, "https://api.crossref.org/works/#{doi}/transform/application/vnd.crossref.unixsd+xml")
          .with(headers: request_headers.merge("Host" => "api.crossref.org", "Accept" => "text/xml;charset=utf-8"))
          .to_return(status: 200, body: fixture, headers: {})
      end

      context "when the doi tab is enabled" do
        before do
          allow(Flipflop).to receive(:enabled?).and_call_original
          allow(Flipflop).to receive(:doi_tab?).and_return(true)
        end

        scenario do
          visit_new_work_page
          fill_in "#{work_type}_doi", with: doi

          accept_confirm do
            click_link "doi-autofill-btn"
          end

          click_on "Descriptions"
          click_on "Additional fields"

          expect(page).to have_content("The following fields were auto-populated", wait: wait)
          expect(page).to have_field("#{work_type}_title", with: "Information School academics and the value of their personal digital archives", wait: wait)

          expect(page).to have_field("#{work_type}_creator__creator_family_name", with: "Drosopoulou", wait: wait)
          expect(page).to have_field("#{work_type}_creator__creator_given_name", with: "Loukia", wait: wait)

          expect(page).to have_field("#{work_type}_creator__creator_family_name", with: "Cox", wait: wait)
          expect(page).to have_field("#{work_type}_creator__creator_given_name", with: "Andrew M.", wait: wait)

          expect(page).to have_field("#{work_type}_creator__creator_organization_name", with: "British Library, London, United Kingdom", wait: wait)
          expect(page).to have_field("#{work_type}_creator__creator_organization_name", with: "Information School, University of Sheffield, United Kingdom", wait: wait)

          expect(page).to have_field("#{work_type}_date_published__date_published_year", with: 2020)
          expect(page).to have_field("#{work_type}_date_published__date_published_month", with: 1)
          expect(page).to have_field("#{work_type}_date_published__date_published_day", with: 1)

          expect(page).to have_field("#{work_type}_abstract", with: "Introduction.This paper explores the value that academics in an information school assign "\
                                                                    "to their digital files and how this relates to their personal information management and "\
                                                                    "personal digital archiving practices. Method. An interpretivist qualitative approach was "\
                                                                    "adopted with data from in-depth interviews and participant-led tours of their digital "\
                                                                    "storage space. Analysis. The approach taken was thematic analysis. Results. Participants "\
                                                                    "placed little value on their digital material beyond the value of its immediate use. They did "\
                                                                    "not attach worth to their digital files for reuse by others, for sentiment, to project their "\
                                                                    "identity or for the study of the development of the discipline or the study of the creative "\
                                                                    "process. This was reflected in storage and file-naming practices, and the lack of curatorial "\
                                                                    "activity. Conclusions. This paper is one of the first to investigate academics' personal "\
                                                                    "information management and personal digital archiving practices, especially to focus on the "\
                                                                    "value of digital possessions. The paper begins to uncover the importance of wider contextual "\
                                                                    "factors in shaping such practices. Institutions need to do more to encourage academics to "\
                                                                    "recognise the diverse types of value in the digital material they create.")

          expect(page).to have_field("#{work_type}_publisher", with: "University of Boras, Faculty of Librarianship, Information, Education and IT", wait: wait)
        end
      end

      context "when the doi tab is disabled" do
        before do
          allow(Flipflop).to receive(:enabled?).and_call_original
          allow(Flipflop).to receive(:doi_tab?).and_return(false)
        end

        scenario do
          visit_new_work_page

          fill_in "doi-search", with: doi

          accept_confirm do
            click_link "doi-autofill-btn"
          end

          click_on "Descriptions"
          click_on "Additional fields"

          expect(page).to have_content("The following fields were auto-populated", wait: wait)
          expect(page).to have_field("#{work_type}_title", with: "Information School academics and the value of their personal digital archives", wait: wait)

          expect(page).to have_field("#{work_type}_creator__creator_family_name", with: "Drosopoulou", wait: wait)
          expect(page).to have_field("#{work_type}_creator__creator_given_name", with: "Loukia", wait: wait)

          expect(page).to have_field("#{work_type}_creator__creator_family_name", with: "Cox", wait: wait)
          expect(page).to have_field("#{work_type}_creator__creator_given_name", with: "Andrew M.", wait: wait)

          expect(page).to have_field("#{work_type}_creator__creator_organization_name", with: "British Library, London, United Kingdom", wait: wait)
          expect(page).to have_field("#{work_type}_creator__creator_organization_name", with: "Information School, University of Sheffield, United Kingdom", wait: wait)

          expect(page).to have_field("#{work_type}_date_published__date_published_year", with: 2020)
          expect(page).to have_field("#{work_type}_date_published__date_published_month", with: 1)
          expect(page).to have_field("#{work_type}_date_published__date_published_day", with: 1)

          expect(page).to have_field("#{work_type}_abstract", with: "Introduction.This paper explores the value that academics in an information school assign "\
                                                                    "to their digital files and how this relates to their personal information management and "\
                                                                    "personal digital archiving practices. Method. An interpretivist qualitative approach was "\
                                                                    "adopted with data from in-depth interviews and participant-led tours of their digital "\
                                                                    "storage space. Analysis. The approach taken was thematic analysis. Results. Participants "\
                                                                    "placed little value on their digital material beyond the value of its immediate use. They did "\
                                                                    "not attach worth to their digital files for reuse by others, for sentiment, to project their "\
                                                                    "identity or for the study of the development of the discipline or the study of the creative "\
                                                                    "process. This was reflected in storage and file-naming practices, and the lack of curatorial "\
                                                                    "activity. Conclusions. This paper is one of the first to investigate academics' personal "\
                                                                    "information management and personal digital archiving practices, especially to focus on the "\
                                                                    "value of digital possessions. The paper begins to uncover the importance of wider contextual "\
                                                                    "factors in shaping such practices. Institutions need to do more to encourage academics to "\
                                                                    "recognise the diverse types of value in the digital material they create.")

          expect(page).to have_field("#{work_type}_publisher", with: "University of Boras, Faculty of Librarianship, Information, Education and IT", wait: wait)
        end
      end
    end
  end
end
