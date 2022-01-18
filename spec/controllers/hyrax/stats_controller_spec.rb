# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::StatsController, type: :controller do
  routes { HykuAddons::Engine.routes }

  let(:user) { create(:admin) }
  let(:account) { build_stubbed(:account) }
  let(:site) { Site.new(account: account) }
  let(:gds_fixture) { File.read(HykuAddons::Engine.root.join("spec", "fixtures", "csv", "gds_chart_fixture.csv")) }
  let(:enabled) { true }

  before do
    allow(Site).to receive(:instance).and_return(site)
  end

  describe "GET #reports" do
    render_views

    before do
      allow(Flipflop).to receive(:enabled?).and_call_original
      allow(Flipflop).to receive(:enabled?).with(:gds_reports).and_return(enabled)
      allow(controller.current_ability).to receive(:can?).with(any_args).and_return(true)
      allow(account).to receive(:gds_reports).and_return(gds_fixture)

      sign_in(user)
    end

    context "when the user is an admin" do
      it "renders a partial" do
        get :reports

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:reports)
      end

      context "when there is data" do
        before do
          get :reports
        end

        it "displays the content" do
          expect(response.body).to include(I18n.t("stats.reports.title"))
          expect(response.body).to include(I18n.t("stats.reports.intro"))
        end

        it "displays the select" do
          expect(response.body).to have_selector("#dashaboard_gds_reports")
        end

        it "displays the correct report titles in the select" do
          reports = response.body.scan(/<option.*>(.*)<\/option>/).flatten
          titles = gds_fixture.lines.map { |line| line.split(",").map(&:strip).delete_at(0) }

          expect(reports).to match_array(titles)
        end
      end

      context "when no data has been entered" do
        let(:gds_fixture) { nil }

        it "does not display the content" do
          get :reports

          expect(response.body).to include(I18n.t("stats.reports.title"))
          expect(response.body).to include(I18n.t("stats.reports.no_reports"))
        end
      end

      context "when the user is a non-admin" do
        let(:enabled) { false }

        it "renders a partial" do
          expect { get :reports }.to raise_error(ActionController::RoutingError)
        end
      end
    end

    context "when the user is a non-admin" do
      let(:user) { create(:user) }

      it "renders a partial" do
        expect { get :reports }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
