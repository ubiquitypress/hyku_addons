# frozen_string_literal: true
require 'rails_helper'

# Copied over from hyrax-doi as a sanity check that things are still working
RSpec.describe HykuAddons::MultitenantExporterJob, type: :job do
  let(:account) { create :account }
  let(:user) { create(:user, email: "test@example.com") }

  before do
    allow(Account).to receive(:find).and_return(account)
    allow(AccountElevator).to receive(:switch!)
    allow(Bulkrax::ExporterJob).to receive(:perform_now)
  end

  it 'switches into the account before delegating into Bulkrax::ExporterJob' do
    described_class.perform_now(account, 1)
    expect(AccountElevator).to have_received(:switch!)
    expect(Bulkrax::ExporterJob).to have_received(:perform_now)
  end
end
