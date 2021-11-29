# frozen_string_literal: true

RSpec.describe HykuAddons::ReindexModelJob do
  let(:account) { create(:account) }
  let(:work) { create(:work) }

  before do
    ActiveJob::Base.queue_adapter = :inline
    allow(work.class).to receive(:reindex_everything)
    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) { work }
  end

  it "#perform_later can enqueue model for reindex" do
    expect { described_class.perform_later(work.class.to_s, account.cname) }.to have_enqueued_job(described_class)
  end

  it "#perform_now can enqueue model for reindex" do
    expect { described_class.perform_now(work.class.to_s, account.cname) }.not_to have_enqueued_job(described_class)
  end
end
