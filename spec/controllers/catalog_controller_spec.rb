# frozen_string_literal: true
require "rails_helper"

RSpec.describe CatalogController, clean: true, type: :controller do
  let!(:work) { PacificArticle.new(title: ["Test"], official_link: official_link, doi_status_when_public: doi_status) }
  let(:file_set) { create(:file_set, visibility: file_visibility) }
  let(:user) { create(:admin) }
  let(:official_link) { nil }
  let(:doi_status) { nil }
  let(:file_visibility) { "restricted" }

  before do
    work.ordered_members << file_set
    work.save!

    sign_in user
  end

  describe "file availability facet" do
    context "when work has public files" do
      let(:file_visibility) { "open" }

      context "and work has findable or registered DOI" do
        let(:doi_status) { "findable" }

        context "and work has official link" do
          let(:official_link) { "https://example.com/link/to/work" }

          it "is available" do
            get "index", params: { q: "" }
            expect(assigns[:response][:facet_counts][:facet_queries].values.first).to eq 1
            expect(assigns[:response][:facet_counts][:facet_queries].values.second).to eq 0
            expect(assigns[:response][:facet_counts][:facet_queries].values.third).to eq 0
          end
        end

        context "and work does not have official link" do
          it "is available" do
            get "index", params: { q: "" }
            expect(assigns[:response][:facet_counts][:facet_queries].values.first).to eq 1
            expect(assigns[:response][:facet_counts][:facet_queries].values.second).to eq 0
            expect(assigns[:response][:facet_counts][:facet_queries].values.third).to eq 0
          end
        end
      end
      context "and work does not have findable or registered DOI" do
        context "and work has official link" do
          let(:official_link) { "https://example.com/link/to/work" }

          it "is available and external link" do
            get "index", params: { q: "" }
            expect(assigns[:response][:facet_counts][:facet_queries].values.first).to eq 1
            expect(assigns[:response][:facet_counts][:facet_queries].values.second).to eq 1
            expect(assigns[:response][:facet_counts][:facet_queries].values.third).to eq 0
          end
        end

        context "and work does not have official link" do
          it "is available" do
            get "index", params: { q: "" }
            expect(assigns[:response][:facet_counts][:facet_queries].values.first).to eq 1
            expect(assigns[:response][:facet_counts][:facet_queries].values.second).to eq 0
            expect(assigns[:response][:facet_counts][:facet_queries].values.third).to eq 0
          end
        end
      end
    end
    context "when work does not have public files" do
      context "and work has findable or registered DOI" do
        let(:doi_status) { "findable" }

        context "and work has official link" do
          let(:official_link) { "https://example.com/link/to/work" }

          it "is not available" do
            get "index", params: { q: "" }
            expect(assigns[:response][:facet_counts][:facet_queries].values.first).to eq 0
            expect(assigns[:response][:facet_counts][:facet_queries].values.second).to eq 0
            expect(assigns[:response][:facet_counts][:facet_queries].values.third).to eq 1
          end
        end

        context "and work does not have official link" do
          it "is not available" do
            get "index", params: { q: "" }
            expect(assigns[:response][:facet_counts][:facet_queries].values.first).to eq 0
            expect(assigns[:response][:facet_counts][:facet_queries].values.second).to eq 0
            expect(assigns[:response][:facet_counts][:facet_queries].values.third).to eq 1
          end
        end
      end
      context "and work does not have findable or registered DOI" do
        context "and work has official link" do
          let(:official_link) { "https://example.com/link/to/work" }

          it "is external link" do
            get "index", params: { q: "" }
            expect(assigns[:response][:facet_counts][:facet_queries].values.first).to eq 0
            expect(assigns[:response][:facet_counts][:facet_queries].values.second).to eq 1
            expect(assigns[:response][:facet_counts][:facet_queries].values.third).to eq 0
          end
        end

        context "and work does not have official link" do
          it "is not available" do
            get "index", params: { q: "" }
            expect(assigns[:response][:facet_counts][:facet_queries].values.first).to eq 0
            expect(assigns[:response][:facet_counts][:facet_queries].values.second).to eq 0
            expect(assigns[:response][:facet_counts][:facet_queries].values.third).to eq 1
          end
        end
      end
    end
  end
end
