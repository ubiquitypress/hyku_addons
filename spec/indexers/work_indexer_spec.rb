# frozen_string_literal: true
RSpec.describe WorkIndexer do
  subject(:solr_document) { service.generate_solr_document }
  let(:service) { described_class.new(work) }
  let(:creator) do
    [
      { creator_family_name: 'Hawking', creator_given_name: 'Stephen', creator_organization_name: '' }
    ].to_json
  end
  let(:contributor) do
    [
      { contributor_family_name: 'Jones', contributor_given_name: 'James Earl', contributor_organization_name: '' }
    ].to_json
  end
  let(:editor) do
    [
      { editor_family_name: '', editor_given_name: '', editor_organization_name: 'University of Cambridge' }
    ].to_json
  end
  let(:work) { create(:work, creator: [creator], editor: [editor], contributor: [contributor]) }

  it "indexes the correct fields" do
    expect(solr_document.fetch('creator_display_ssim')).to eq ["Hawking, Stephen"]
    expect(solr_document.fetch('contributor_display_ssim')).to eq ["Jones, James Earl"]
    expect(solr_document.fetch('editor_display_ssim')).to eq ["University of Cambridge"]
  end

  context 'with extra blankspace' do
    let(:contributor) do
      [
        { contributor_family_name: 'Jones ', contributor_given_name: 'James Earl ', contributor_organization_name: '' }
      ].to_json
    end

    it "indexes the correct fields" do
      expect(solr_document.fetch('creator_display_ssim')).to eq ["Hawking, Stephen"]
      expect(solr_document.fetch('contributor_display_ssim')).to eq ["Jones, James Earl"]
      expect(solr_document.fetch('editor_display_ssim')).to eq ["University of Cambridge"]
    end
  end

  context "account_cname_tesim" do
    let(:account) { create(:account, cname: 'hyky-test.me') }

    before do
      allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
        block&.call
      end

      Apartment::Tenant.switch!(account.tenant) do
        Site.update(account: account)
        work
      end
    end

    it "indexer has the account_cname" do
      expect(solr_document.fetch("account_cname_tesim")).to eq(account.cname)
    end
  end
end
