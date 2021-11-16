# frozen_string_literal: true
require "spec_helper"
require File.expand_path("../../../helpers/user_with_work_context.rb", __dir__)

RSpec.describe CatalogController, multitenant: true do
  include_context "user with work context" do
    let(:params) { { verb: "Identify" } }

    before do
      get oai_catalog_path(params)
    end

    it "contains repository name" do
      expect(xml.at_xpath("//xmlns:repositoryName").text).to eql "example"
    end

    it "contains base url" do
      expect(xml.at_xpath("//xmlns:baseURL").text).to eql "http://#{account.cname}/catalog/oai?locale=en"
    end

    it "contains admin email" do
      expect(xml.at_xpath("//xmlns:adminEmail").text).to eql "some@example.com"
    end

    it "contains repository prefix/identifier" do
      expect(
        xml.at_xpath("//oai-identifier:repositoryIdentifier", "oai-identifier" => "http://www.openarchives.org/OAI/2.0/oai-identifier").text
      ).to eql "hyku.example.com"
    end

    it "contains sample identifier" do
      expect(
        xml.at_xpath("//oai-identifier:sampleIdentifier", "oai-identifier" => "http://www.openarchives.org/OAI/2.0/oai-identifier").text
      ).to eql "hyku.example.com:#{work.id}"
    end
  end
end
