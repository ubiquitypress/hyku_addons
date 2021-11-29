# frozen_string_literal: true

RSpec.describe HykuAddons::ReindexAvailableWorksJob do
  let(:account) { create(:account) }
  let(:work) { create(:work) }
  let(:site) { instance_double(Site) }

  before do
    ActiveJob::Base.queue_adapter = :test
    allow(site).to receive(:available_works).and_return([work.class.to_s])

    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      Site.update(account: account)
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) { work }
  end

  it "#perform_later can enqueue model for reindex" do
    expect { described_class.perform_later([account.cname]) }.to have_enqueued_job(described_class)
  end

  it "#perform_now can enqueue model for reindex" do
    expect { described_class.perform_now([account.cname]) }.not_to have_enqueued_job(described_class)
  end
end
