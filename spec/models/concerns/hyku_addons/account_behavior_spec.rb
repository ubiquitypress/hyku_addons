# frozen_string_literal: true

require "spec_helper"

RSpec.describe HykuAddons::AccountBehavior do
  subject(:account) { Account.new }
  let(:cache_enabled) { false }
  describe "#switch!" do
    before do
      account.build_solr_endpoint(url: "http://example.com/solr/")
      account.build_fcrepo_endpoint(url: "http://example.com/fedora", base_path: "/dev")
      account.build_redis_endpoint(namespace: "foobaz")
      account.build_datacite_endpoint(mode: "test", prefix: "10.1234", username: "user123", password: "pass123")
      allow(Flipflop).to receive(:enabled?).with(:cache_api).and_return(cache_enabled)
      allow(Redis.current).to receive(:id).and_return "redis://localhost:6379/0"
      account.switch!
    end

    after do
      account.reset!
    end

    it "switches the DataCite connection" do
      expect(Hyrax::DOI::DataCiteRegistrar.mode).to eq "test"
      expect(Hyrax::DOI::DataCiteRegistrar.prefix).to eq "10.1234"
      expect(Hyrax::DOI::DataCiteRegistrar.username).to eq "user123"
      expect(Hyrax::DOI::DataCiteRegistrar.password).to eq "pass123"
      expect(Rails.application.routes.default_url_options[:host]).to eq account.cname
    end

    context "when cache is enabled" do
      let(:cache_enabled) { true }

      it "uses Redis as a cache store" do
        expect(Rails.application.config.action_controller.perform_caching).to be_truthy
        expect(ActionController::Base.perform_caching).to be_truthy
        expect(Rails.application.config.cache_store).to eq([:redis_cache_store, { namespace: "foobaz", url: "redis://localhost:6379/0" }])
      end

      it "reverts to using file store when Flipflop is off" do
        allow(Flipflop).to receive(:enabled?).with(:cache_api).and_return(false)
        account.switch!
        expect(Rails.application.config.cache_store).to eq([:file_store, nil])
      end
    end

    context "when cache is disabled" do
      let(:cache_enabled) { false }

      it "uses the file store" do
        expect(Rails.application.config.action_controller.perform_caching).to be_falsey
        expect(ActionController::Base.perform_caching).to be_falsey
        expect(Rails.application.config.cache_store).to eq([:file_store, nil])
      end
    end
  end

  describe "#switch" do
    let!(:previous_datacite_prefix) { Hyrax::DOI::DataCiteRegistrar.prefix }
    let!(:previous_datacite_username) { Hyrax::DOI::DataCiteRegistrar.username }
    let!(:previous_datacite_password) { Hyrax::DOI::DataCiteRegistrar.password }
    let!(:previous_account_cname) { account.cname }

    before do
      account.build_solr_endpoint(url: "http://example.com/solr/")
      account.build_fcrepo_endpoint(url: "http://example.com/fedora", base_path: "/dev")
      account.build_redis_endpoint(namespace: "foobaz")
      account.build_datacite_endpoint(mode: "test", prefix: "10.1234", username: "user123", password: "pass123")
    end

    after do
      account.reset!
    end

    it "switches to the account-specific connection" do
      account.switch do
        expect(Hyrax::DOI::DataCiteRegistrar.mode).to eq "test"
        expect(Hyrax::DOI::DataCiteRegistrar.prefix).to eq "10.1234"
        expect(Hyrax::DOI::DataCiteRegistrar.username).to eq "user123"
        expect(Hyrax::DOI::DataCiteRegistrar.password).to eq "pass123"
        expect(Rails.application.routes.default_url_options[:host]).to eq account.cname
      end
    end

    it "resets the active connections back to the defaults" do
      account.switch do
        # no-op
      end
      expect(Hyrax::DOI::DataCiteRegistrar.mode).to eq "test"
      expect(Hyrax::DOI::DataCiteRegistrar.prefix).to eq previous_datacite_prefix
      expect(Hyrax::DOI::DataCiteRegistrar.username).to eq previous_datacite_username
      expect(Hyrax::DOI::DataCiteRegistrar.password).to eq previous_datacite_password
      expect(Rails.application.routes.default_url_options[:host]).to eq previous_account_cname
    end

    context "with missing endpoint" do
      it "returns a NilDataCiteEndpoint" do
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

  describe "Settings Customisations" do
    let(:account) { build(:account) }
    context "settings jsonb keys" do
      it "has contact_email key that is not empty" do
        expect(account.settings["contact_email"]).to eq "abc@abc.com"
        expect(account.settings["contact_email"]).to be_an_instance_of(String)
      end

      it "has key weekly_email_list" do
        expect(account.settings["weekly_email_list"]).to  eq ["aaa@aaa.com", "bbb@bl.uk"]
        expect(account.settings["weekly_email_list"]).to be_an_instance_of(Array)
      end

      it "has non empty month_email_list" do
        expect(account.settings["monthly_email_list"]).to  eq ["aaa@aaa.com", "bbb@bl.uk"]
        expect(account.settings["monthly_email_list"]).to be_an_instance_of(Array)
      end

      it "has non empty yearly_email_list" do
        expect(account.settings["yearly_email_list"]).to  eq ["aaa@aaa.com", "bbb@bl.uk"]
        expect(account.settings["yearly_email_list"]).to be_an_instance_of(Array)
      end

      it "has google_scholarly_work_types" do
        expect(account.google_scholarly_work_types).to  eq ["Article", "Book", "ThesisOrDissertation", "BookChapter"]
        expect(account.google_scholarly_work_types).to be_an_instance_of(Array)
        expect(account.google_scholarly_work_types).to include("Book")
      end
    end

    context "settings from environment variable" do
      it "check all boolean truthy values" do
        ["allow_signup", "shared_login"].each do |key|
          expect(account.settings[key]).to eq("true")
        end
      end

      it "contains gtm_id" do
        expect(account.settings["gtm_id"]).to eq "GTM-123456"
      end

      it "allows UA google_analytics_id" do
        expect(account.settings["google_analytics_id"]).to eq "UA-123456-12"
      end

      it "allows G4A google_analytics_id" do
        account.settings["google_analytics_id"] = "G-ABCDE12345"
        expect(account.settings["google_analytics_id"]).to eq "G-ABCDE12345"
      end

      it "contains email_format" do
        expect(account.settings["email_format"]).to include("@pacificu.edu")
      end
    end
  end

  describe "valid?" do
    before do
      account.tenant = uuid
      account.valid?
    end

    context "with no tenant UUID" do
      let(:uuid) { nil }

      it "sets a valid tenant UUID" do
        expect(account.tenant).to be_present
        expect(account.errors[:tenant]).to be_empty
      end
    end

    context "with a valid tenant UUID" do
      let(:uuid) { SecureRandom.uuid }

      it "respects the existing tenant UUID" do
        expect(account.tenant).to eq uuid
        expect(account.errors[:tenant]).to be_empty
      end
    end

    context "with an invalid tenant UUID" do
      let(:uuid) { "foo-bar" }

      it "respects the existing tenant UUID" do
        expect(account.tenant).to eq uuid
      end

      it "is invalid" do
        expect(account.errors[:tenant]).not_to be_empty
      end
    end
  end

  describe "public_settings" do
    before do
      Account.private_settings.each do |setting|
        account.settings[setting] = ["foo"]
      end
    end

    it "excludes private settings" do
      Account.private_settings do |setting|
        expect(account.public_settings).not_to include(setting)
      end
    end
  end

  describe "smtp_settings" do
    context "with an existing account" do
      let!(:account) { create :account, smtp_settings: { authentication: "login" } }

      it "respects the existing settings" do
        expect(account.reload.smtp_settings.with_indifferent_access).to include(authentication: "login")
      end

      it "adds missing smtp config keys" do
        settings = Account.find(account.id).reload.smtp_settings

        HykuAddons::PerTenantSmtpInterceptor.available_smtp_fields.each do |setting_name|
          expect(settings).to have_key(setting_name)
        end
      end
    end
  end

  describe "cross tenant shared search" do
    context "settings keys" do
      it "has default value for #shared_search" do
        expect(account.search_only).to eq false
      end
    end

    context "boolean method checks" do
      it "#shared_search_enabled? defaults to true using Flipflop" do
        expect(account.shared_search_enabled?).to be_truthy
      end

      it "#shared_search_tenant? defaults to false" do
        expect(account.search_only?).to be_falsey
      end
    end

    context "can add and remove Full Account from shared search" do
      let(:normal_account) { create(:account) }
      let(:cross_search_solr) { create(:solr_endpoint, url: "http://solr:8983/solr/hydra-cross-search-tenant") }

      let(:shared_search_account) { create(:account, search_only: true, full_account_ids: [normal_account.id], solr_endpoint: cross_search_solr, fcrepo_endpoint: nil) }

      it "contains full_account" do
        expect(shared_search_account.full_accounts).to be_truthy
        expect(shared_search_account.full_accounts.size).to eq 1
      end

      it "removes full_account" do
        shared_search_account.full_account_ids = []
        expect(shared_search_account.full_accounts.size).to eq 0
      end
    end
  end
end
