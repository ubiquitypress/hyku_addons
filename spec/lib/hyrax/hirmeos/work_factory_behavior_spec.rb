# frozen_string_literal: true
RSpec.describe Hyrax::Hirmeos::WorkFactory do
  WebMock.allow_net_connect!
  let(:work) { create(:work) }
  let(:account) { build(:account) }

  before do
    allow(Site).to receive(:account).and_return(account)
  end

  it "Creates works with the correct structure" do
    structure = {
      "title": [
        work.title[0].to_s
      ],
      "uri": [
        {
          "uri": "http://lvh.me:3000/concern/generic_works/#{work.id}",
          "canonical": true
        },
        {
          "uri": "https://#{account.frontend_url}/work/ns/#{work.id}"
        },
        {
          "uri": "urn:uuid:#{work.id}"
        }
      ],
      "type": "repository-work",
      "parent": nil,
      "children": nil
    }
    factory_work = described_class.for(resource: work)
    expect(factory_work.to_json).to eq(structure.to_json)
  end
end
