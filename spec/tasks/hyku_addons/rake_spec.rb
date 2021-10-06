# frozen_string_literal: true

require 'rake'

RSpec.describe "HykuAddons Rake tasks" do
  before(:all) do
    Rails.application.load_tasks
  end

  describe 'hyku:account:create_shared' do
    let(:account_1) { create(:account, name: 'account_1') }
    let(:account_2) { create(:account, name: 'account_2') }
    let(:account) { create(:account, name: 'sample', search_only: true, full_account_ids: [account_1.id, account_2.id]) }
    let(:create_account) { instance_double(CreateAccount) }

    it 'raises error with no tenant_list' do
      expect { run_task('hyku:account:create_shared', 'sample', '', 'sample.hyku.docker') }.to raise_error(StandardError, /Provide a list of tenants seperated by commas as last argument/)
    end

    it 'creates a shared search tenant' do
      allow(create_account).to receive(:save).and_return(account)

      Rake::Task['hyku:account:create_shared'].invoke('sample', '15x6', 'sample.hyku.docker', account_1.id, account_2.id)

      expect(account.full_account_ids).to eq [account_1.id, account_2.id]
      expect(account.search_only?).to be_truthy
    end
  end
end
