require 'spec_helper'

RSpec.describe 'OIA-PMH Identify Request', multitenant: true do
  let(:xml) { Nokogiri::XML(response.body) }

  let(:user)    { create(:user) }
  let(:account) { create(:account, oai_admin_email: 'some@example.com', name: 'example') }
  let(:work)    { create(:work, user: user) }
  let(:identifier) { work.id }

  before do
    Site.update(account: account)
    allow(Apartment::Tenant).to receive(:switch).with(account.tenant) do |&block|
      block.call
    end
    host! account.cname
    # debugger
    get '/catalog/oai?verb=Identify'
  end


  it "contains repository name" do
    expect(xml.at_xpath('//xmlns:repositoryName').text).to eql 'example'
  end

  it "contains base url" do
    expect(xml.at_xpath('//xmlns:baseURL').text).to eql "http://#{account.cname}/catalog/oai?locale=en"
  end

  it "contains admin email" do
    expect(xml.at_xpath('//xmlns:adminEmail').text).to eql 'some@example.com'
  end

  it "contains repository prefix/identifier" do
    expect(
      xml.at_xpath('//oai-identifier:repositoryIdentifier', 'oai-identifier' => "http://www.openarchives.org/OAI/2.0/oai-identifier").text
    ).to eql 'hyku'
  end

  it "contains sample identifier" do
    expect(
      xml.at_xpath('//oai-identifier:sampleIdentifier', 'oai-identifier' => "http://www.openarchives.org/OAI/2.0/oai-identifier").text
    ).to eql 'oai:hyku:806bbc5e-8ebe-468c-a188-b7c14fbe34df'
  end
end
