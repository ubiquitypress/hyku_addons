# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::StatsController, type: :controller do
  routes { HykuAddons::Engine.routes }

  let(:user) { create(:admin) }
  let(:account) { create(:account) }
  let(:site) { Site.new(account: account) }

  before do
    allow(Site).to receive(:instance).and_return(site)
  end

  describe "GET #reports" do
    render_views

    before do
      allow(controller.current_ability).to receive(:can?).with(any_args).and_return(true)
      sign_in(user)
    end

    context "when the user is an admin" do
      it "renders a partial" do
        get :reports

        expect(response).to render_template(:reports)
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
