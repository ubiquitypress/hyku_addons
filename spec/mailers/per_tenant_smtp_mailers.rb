# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::ContactMailer, type: :feature do
  let(:contact_form) do
    Hyrax::ContactForm.new(
      email: 'test@example.com',
      category: 'Test',
      subject: 'Test',
      name: 'Test Tester',
      message: 'This is a test'
    )
  end
  let(:mail_from) { "test@test.edu" }

  describe "reset_password_instructions" do
    context "with per tenant SMTP" do
      let!(:account) { Account.create(name: 'test', tenant: 'test', cname: 'test.lvh.me', locale_name: 'test') }
      let(:mail) { described_class.contact(contact_form) }

      before do
        allow(Settings).to receive(:tenant_settings_filename).with('test').and_return(HykuAddons::Engine.root.join('spec', 'fixtures', 'settings', 'test-TEST.yml'))
        account.switch!
        allow(Site).to receive(:contact_email).and_return('me@example.com')
        mail.deliver
      end

      it "replaces the email headers" do
        expect(mail.from).to eq ["test@test.edu"]
        settings = mail.delivery_method.settings
        expect(settings[:address]).to eq "test.edu"
        expect(settings[:user_name]).to eq "username"
        expect(settings[:password]).to eq "password"
        expect(settings[:domain]).to eq "test.custom_domain.com"
      end
    end
  end
end
