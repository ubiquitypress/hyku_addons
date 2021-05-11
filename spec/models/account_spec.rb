# frozen_string_literal: true

RSpec.describe Account, type: :model do
  describe 'Settings' do
    let!(:account) { described_class.create(name: 'example', tenant: 'example', cname: 'example.com') }

    after do
      # FIXME: move this out to a global before/after?
      account.reset!
    end

    it 'loads settings' do
      account.switch!
      expect(Settings.google_analytics_id).to eq nil
    end

    context 'with a settings.yml override' do
      before do
        account.update(locale_name: 'test')
        allow(account).to receive(:tenant_settings_filename).with('test').and_return(HykuAddons::Engine.root.join('spec', 'fixtures', 'settings', 'test-TEST.yml'))
      end

      it 'loads settings' do
        account.switch!
        expect(Settings.google_analytics_id).to eq 'yml-id'
      end
    end

    context 'with environment variables' do
      before do
        ENV['SETTINGS__GOOGLE_ANALYTICS_ID'] = 'env-id'
        ENV['SETTINGS__OTHER_SETTING'] = 'moomin'
      end

      after do
        ENV.delete('SETTINGS__GOOGLE_ANALYTICS_ID')
        ENV.delete('SETTINGS__OTHER_SETTING')
      end

      it 'loads settings' do
        account.switch!
        expect(Settings.google_analytics_id).to eq 'env-id'
        expect(Settings.other_setting).to eq 'moomin'
      end

      context 'with locale_name' do
        before do
          account.update(locale_name: 'test')
          ENV['SETTINGS__TEST__GOOGLE_ANALYTICS_ID'] = 'env-test-id'
        end

        after do
          ENV.delete('SETTINGS__TEST__GOOGLE_ANALYTICS_ID')
        end

        it 'loads settings' do
          account.switch!
          expect(Settings.google_analytics_id).to eq 'env-test-id'
        end

        it 'still loads fallback settings' do
          account.switch!
          expect(Settings.other_setting).to eq 'moomin'
        end
      end
    end

    context 'with DB settings' do
      before do
        account.settings['google_analytics_id'] = 'db-id'
        account.save
      end

      it 'loads settings' do
        account.switch!
        expect(Settings.google_analytics_id).to eq 'db-id'
      end
    end

    describe 'tenant_settings_filename' do
      it 'returns a standardized filename' do
        account.switch!
        expect(account.tenant_settings_filename('test')).to eq Rails.root.join('config', 'settings', 'test-TEST.yml')
      end
    end

    context 'Hyrax configuration' do
      before do
        account.settings['google_analytics_id'] = 'GA-TEST1234'
        account.save
      end

      it 'dynamically loads google analytics id from Settings' do
        expect { account.switch! }.to change { Hyrax.config.google_analytics_id }.to('GA-TEST1234')
      end
    end
  end
end
