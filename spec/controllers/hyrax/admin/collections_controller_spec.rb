# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::Dashboard::CollectionsController, type: :controller do
  routes { Hyrax::Engine.routes }
  let(:collection) { create(:collection) }
  let(:user) { create(:admin) }

  describe "GET #edit" do
    render_views

    before do
      allow(controller.current_ability).to receive(:can?).with(any_args).and_return(true)
      sign_in(user)
    end

    it "renders a partial" do
      get :edit, params: { id: collection.id }

      expect(response).to render_template(:edit)
      expect(response).to render_template(partial: "records/edit_fields/_default")
      # We are overriding this partial and so we shouldn't find the flag
      expect(response.body).not_to have_selector("span[data-flag=hyrax-orcid-default]")
    end
  end
end
