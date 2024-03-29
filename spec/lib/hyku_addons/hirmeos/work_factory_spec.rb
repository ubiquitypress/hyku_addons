# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::Hirmeos::WorkFactory do
  WebMock.allow_net_connect!
  let(:work) { build_stubbed(:work) }
  let(:account) { build_stubbed(:account) }

  before do
    Rails.application.routes.default_url_options[:host] = "localhost:3000"
    allow(Site).to receive(:account).and_return(account)
  end

  it "Creates works with the correct structure" do
    structure = {
      title: [
        work.title[0].to_s
      ],
      uri: [
        {
          uri: "http://localhost:3000/concern/generic_works/#{work.id}"
        },
        {
          uri: "https://#{account.frontend_url}/work/sc/#{work.id}"
        },
        {
          uri: "https://#{account.frontend_url}/work/ns/#{work.id}"
        },
        {
          uri: "urn:uuid:#{work.id}",
          canonical: true
        }
      ],
      type: "repository-work",
      parent: nil,
      children: nil
    }
    factory_work = described_class.for(resource: work)
    expect(factory_work.to_json).to eq(structure.to_json)
  end
end
