# frozen_string_literal: true
RSpec.describe "CollectionIndexerOverride" do
  subject(:solr_document) { service.generate_solr_document }
  let(:service) { CollectionIndexer.new(collection) }
  let(:collection) { create(:collection) }

  context "account_cname_tesim" do
    let(:account) { create(:account, cname: "hyky-test.me") }

    before do
      allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
        block&.call
      end

      Apartment::Tenant.switch!(account.tenant) do
        Site.update(account: account)
        collection
      end
    end

    it "indexer has the account_cname" do
      puts solr_document.inspect
      expect(solr_document.fetch("account_cname_tesim")).to eq(account.cname)
    end
  end
end
