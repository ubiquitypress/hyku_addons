# frozen_string_literal: true

require 'rake'

RSpec.describe "HykuAddons Rake tasks" do
  before(:all) do
    Rails.application.load_tasks
  end

  describe 'hyku:account:create_shared' do
    let(:account_1) { create(:account, name: 'account_1') }
    let(:account_2) { create(:account, name: 'account_2') }
    let(:account) do
      build(:account, name: 'sample', search_only: true, full_account_ids: [account_1.id, account_2.id])
    end

    after do
      account_1.destroy
      account_2.destroy
    end

    it 'raises error with no tenant_list' do
      expect { run_task('hyku:account:create_shared', 'sample', '', 'sample.hyku.docker', '') }.to raise_error(ArgumentError, /Provide a list of tenants seperated by commas as last argument/)
    end

    context 'with valid parameters' do
      let(:create_account) { instance_double(CreateAccount) }
      let(:client) { double }
      let(:uuid) { SecureRandom.uuid }

      before do
        allow(Blacklight.default_index).to receive(:connection).and_return(client)
        allow(client).to receive(:get).and_return('collections' => [account.tenant])
        allow(Apartment::Tenant.adapter).to receive(:connect_to_new).and_return('')
      end

      it 'can create a shared search tenant' do
        allow(create_account).to receive(:save).and_return(account)

        run_task('hyku:account:create_shared', 'sample', uuid, 'sample.hyku.docker', account_1.id, account_2.id)

        expect(account.full_account_ids).to eq [account_1.id, account_2.id]
        expect(account.search_only?).to be_truthy
      end
    end

    context 'account is not valid?' do
      let(:bad_uuid) { 'd8c8a00a-dd0d-4db1-be93-f48eac2bb5edc' }
      let(:bad_account) do
        build(:account, name: 'sample', search_only: true, full_account_ids: [account_1.id, account_2.id])
      end

      it 'raises error with bad uuid' do
        bad_account.tenant = bad_uuid
        bad_account.valid?
        expect { run_task('hyku:account:create_shared', 'search1', 'd8c8a00a-dd0d-4db1-be93-f48eac2bb5edc', 'dashboard.search1.ubiquityrepo-ah.website', account_1.id) }
          .to raise_error(StandardError, "The following errors occurred - #{bad_account.errors.messages}")
      end
    end
  end
end
