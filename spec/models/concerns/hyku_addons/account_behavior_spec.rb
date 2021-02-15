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

  describe 'Settings Customisations' do
    let(:account) { build(:account) }
    context 'settings jsonb keys' do
      it " #remove_settings_hash_key_with_nil_value before_save callback can remove initialized values settings hash" do
        account = Account.new
        account.send(:remove_settings_hash_key_with_nil_value)
        ['help_texts', 'work_unwanted_fields', 'required_json_property', 'metadata_labels', 'html_required'].each do |key|
          expect(account.settings[key].blank?).to eq true
        end
      end

      it 'has contact_email key that is not empty' do
        expect(account.settings['contact_email']).to eq 'abc@abc.com'
        expect(account.settings['contact_email']).to be_an_instance_of(String)
      end

      it "has key weekly_email_list" do
        expect(account.settings['weekly_email_list']).to  eq ["aaa@aaa.com", "bbb@bl.uk"]
        expect(account.settings['weekly_email_list']).to be_an_instance_of(Array)
      end

      it "has non empty month_email_list" do
        expect(account.settings['monthly_email_list']).to  eq ["aaa@aaa.com", "bbb@bl.uk"]
        expect(account.settings['monthly_email_list']).to be_an_instance_of(Array)
      end

      it "has non empty yearly_email_list" do
        expect(account.settings['yearly_email_list']).to  eq ["aaa@aaa.com", "bbb@bl.uk"]
        expect(account.settings['yearly_email_list']).to be_an_instance_of(Array)
      end

      it "has google_scholarly_work_types" do
        expect(account.google_scholarly_work_types).to  eq ['Article', 'Book', 'ThesisOrDissertation', 'BookChapter']
        expect(account.google_scholarly_work_types).to be_an_instance_of(Array)
        expect(account.google_scholarly_work_types).to include('Book')
      end

      it " has index_record_to_shared_search" do
        expect(account.index_record_to_shared_search).to eq "true"
      end
    end

    context "settings from environment variable" do
      it "check all boolean truthy values" do
        ['redirect_on', 'allow_signup', "hide_form_relationship_tab", "shared_login"].each do |key|
          expect(account.settings[key]).to eq("true")
        end
      end

      it "contains live key" do
        expect(account.settings['live']).to eq "commons.pacificu.edu"
      end

      it "has enabled_doi" do
        expect(account.settings['enabled_doi']).to be_falsey
      end

      it "contains gtm_id" do
        expect(account.settings['gtm_id']).to eq "GTM-123456"
      end

      it "contains work_type_list" do
        expect(account.settings['work_type_list']).to include("ArticleWork,BookWork")
      end

      it "has email_hint_text" do
        expect(account.settings['email_hint_text']).to include("Please enter your email")
      end

      it "contains email_format" do
        expect(account.settings['email_format']).to include("@pacificu.edu")
      end

      it "has help_texts" do
        expect(account.settings['help_texts']).to include("subject" => "Select word(s)  about your work.")
      end

      it "has work_unwanted_fields" do
        expect(account.settings["work_unwanted_fields"]).to include("news_clipping" => "institution", "article" => "institution")
      end

      it "contains required_json_property" do
        expect(account.settings['required_json_property'].keys).to include('media', 'text_work')
        expect(account.settings['required_json_property']['media']).to include("creator_institutional_relationship")
      end

      it "has creator_fields" do
        expect(account.settings["creator_fields"]).to include("creator_group,creator_name_type")
      end

      it "contains contributor_fields" do
        expect(account.settings["contributor_fields"]).to include("contributor_suffix,contributor_institutional_relationship")
      end

      it "has metadata_labels" do
        expect(account.settings['metadata_labels']).to include("institutional_relationship" => "Institution", "family_name" => "Last Name")
        expect(account.settings['metadata_labels']).to be_an_instance_of(Hash)
      end

      it "institutional_relationship_picklist" do
        expect(account.settings['institutional_relationship_picklist']).to eq "false"
      end

      it "has institutional_relationship key" do
        expect(account.settings['institutional_relationship']).to eq "Pacific University,Other"
      end

      it "contributor_roles" do
        expect(account.settings['contributor_roles']).to include("Advisor")
        expect(account.settings['contributor_roles']).to be_an_instance_of(Array)
      end

      it "contains an array of creator_roles" do
        expect(account.settings['creator_roles']).to include("Faculty")
        expect(account.settings['creator_roles']).to be_an_instance_of(Array)
      end

      it "has a hash of html_required" do
        expect(account.settings['html_required']).to include("contributor" => "false")
        expect(account.settings['html_required']).to be_an_instance_of(Hash)
      end

      it "contails an array of licence_list" do
        expect(account.settings['licence_list']).to include("name" => "CC BY 4.0 Attribution", "url" => "https://creativecommons.org/licenses/by/4.0/")
        expect(account.settings['licence_list']).to be_an_instance_of(Array)
      end
    end

    context 'data jsonb keys' do
      it "has value in is_parent" do
        expect(account.is_parent).to be_falsey
      end
    end
  end
end
