# frozen_string_literal: true
include Warden::Test::Helpers

RSpec.shared_context 'user with work context' do
  let(:xml) { Nokogiri::XML(response.body) }

  let(:user)       { create(:user) }
  let(:account)    do
    create(:account,
           name:   'example',
           oai_admin_email: 'some@example.com',
           oai_prefix:      'hyku.example.com',
           oai_sample_identifier: work.id)
  end
  let!(:work)      { create(:work, user: user, visibility: 'open') }
  let(:identifier) { work.id }

  before do
    Site.update(account: account)
    allow(Apartment::Tenant).to receive(:switch).with(account.tenant) do |&block|
      block.call
    end
    host! account.cname
  end
end