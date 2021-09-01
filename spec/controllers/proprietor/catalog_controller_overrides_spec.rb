# frozen_string_literal: true

RSpec.describe CatalogController do
  describe "GET /oai" do
    before do
      allow(Flipflop).to receive(:enabled?).with(:oai_endpoint).and_return(oai_enabled)
      allow(Flipflop).to receive(:enabled?).with(:cache_enabled).and_return(false)
    end

    context "with OAI enabled" do
      let(:oai_enabled) { true }

      it "is successful" do
        get :oai
        expect(response).to be_successful
        expect(response.content_type).to eq 'text/xml'
      end
    end

    context "with OAI disbaled" do
      let(:oai_enabled) { false }

      it "is raises a routing error" do
        expect { get :oai }.to raise_error(ActionController::RoutingError, 'Enable the OAI Endpoint feature first')
      end
    end
  end
end
