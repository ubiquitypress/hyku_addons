# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HykuAddons::AccountBehavior do
  subject(:account) { Account.new }

  describe '#switch!' do
    before do
      account.build_solr_endpoint(url: 'http://example.com/solr/')
      account.build_fcrepo_endpoint(url: 'http://example.com/fedora', base_path: '/dev')
      account.build_redis_endpoint(namespace: 'foobaz')
      account.build_datacite_endpoint(mode: 'test', prefix: '10.1234', username: 'user123', password: 'pass123')
      account.switch!
    end

    after do
      account.reset!
    end

    it 'switches the DataCite connection' do
      expect(Hyrax::DOI::DataCiteRegistrar.mode).to eq 'test'
      expect(Hyrax::DOI::DataCiteRegistrar.prefix).to eq '10.1234'
      expect(Hyrax::DOI::DataCiteRegistrar.username).to eq 'user123'
      expect(Hyrax::DOI::DataCiteRegistrar.password).to eq 'pass123'
      expect(Rails.application.routes.default_url_options[:host]).to eq account.cname
    end
  end

  describe '#switch' do
    let!(:previous_datacite_mode) { Hyrax::DOI::DataCiteRegistrar.mode }
    let!(:previous_datacite_prefix) { Hyrax::DOI::DataCiteRegistrar.prefix }
    let!(:previous_datacite_username) { Hyrax::DOI::DataCiteRegistrar.username }
    let!(:previous_datacite_password) { Hyrax::DOI::DataCiteRegistrar.password }
    let!(:previous_account_cname) { account.cname }

    before do
      account.build_solr_endpoint(url: 'http://example.com/solr/')
      account.build_fcrepo_endpoint(url: 'http://example.com/fedora', base_path: '/dev')
      account.build_redis_endpoint(namespace: 'foobaz')
      account.build_datacite_endpoint(mode: 'test', prefix: '10.1234', username: 'user123', password: 'pass123')
    end

    after do
      account.reset!
    end

    it 'switches to the account-specific connection' do
      account.switch do
        expect(Hyrax::DOI::DataCiteRegistrar.mode).to eq 'test'
        expect(Hyrax::DOI::DataCiteRegistrar.prefix).to eq '10.1234'
        expect(Hyrax::DOI::DataCiteRegistrar.username).to eq 'user123'
        expect(Hyrax::DOI::DataCiteRegistrar.password).to eq 'pass123'
        expect(Rails.application.routes.default_url_options[:host]).to eq account.cname
      end
    end

    it 'resets the active connections back to the defaults' do
      account.switch do
        # no-op
      end
      expect(Hyrax::DOI::DataCiteRegistrar.mode).to eq previous_datacite_mode
      expect(Hyrax::DOI::DataCiteRegistrar.prefix).to eq previous_datacite_prefix
      expect(Hyrax::DOI::DataCiteRegistrar.username).to eq previous_datacite_username
      expect(Hyrax::DOI::DataCiteRegistrar.password).to eq previous_datacite_password
      expect(Rails.application.routes.default_url_options[:host]).to eq previous_account_cname
    end

    context 'with missing endpoint' do
      it 'returns a NilDataCiteEndpoint' do
        account.datacite_endpoint = nil
        expect(account.datacite_endpoint).to be_kind_of NilDataCiteEndpoint
        expect(account.datacite_endpoint.persisted?).to eq false
        account.switch do
          expect(Hyrax::DOI::DataCiteRegistrar.mode).to eq nil
          expect(Hyrax::DOI::DataCiteRegistrar.prefix).to eq nil
          expect(Hyrax::DOI::DataCiteRegistrar.password).to eq nil
          expect(Hyrax::DOI::DataCiteRegistrar.username).to eq nil
          expect(Rails.application.routes.default_url_options[:host]).to eq nil
        end
      end
    end
  end
end
