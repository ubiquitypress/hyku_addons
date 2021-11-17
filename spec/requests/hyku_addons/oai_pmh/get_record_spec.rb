# frozen_string_literal: true
require "spec_helper"
require File.expand_path("../../../helpers/user_with_work_context.rb", __dir__)

RSpec.describe CatalogController, multitenant: true do
  include_context "user with work context"
  describe "GetRecord" do
    let(:params) do
      {
        verb: "GetRecord",
        identifier: "#{account.oai_prefix}:#{work.id}",
        metadataPrefix: "oai_dc"
      }
    end

    it "shows public records" do
      get oai_catalog_path(params)
      expect(response.body).not_to include("idDoesNotExist")
    end

    context "with a restricted work" do
      before do
        work.update visibility: "restricted"
        get oai_catalog_path(params)
      end

      it "returns a not found error" do
        expect(response.body).to include("idDoesNotExist")
      end
    end
  end
end
