# frozen_string_literal: true

RSpec.describe HykuAddons::ReindexAvailableWorksJob, type: :job do
  let(:account) { create(:account) }
  let(:work) { build_stubbed(:work) }
  let(:site) { instance_double(Site) }

  before do
    allow(site).to receive(:available_works).and_return([work.class.to_s])

    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      Site.update(account: account)
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) { work }
  end

  it "can enqueue job with correct parameters" do
    expect { described_class.perform_later([account.cname]) }.to have_enqueued_job(described_class).with([account.cname])
  end

  it "can enqueue ReindexModelJob with correct paramters" do
    expect do
      described_class.perform_now([account.cname], cname_doi_mint: [account.cname])
    end.to have_enqueued_job(HykuAddons::ReindexModelJob).at_least(:once)
                                                         .with(work.class.to_s, account.cname, options: { cname_doi_mint: [account.cname] })
  end
end
