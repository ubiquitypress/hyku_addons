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

  describe "reset_password_instructions" do
    context "with per tenant SMTP" do
      let!(:account) { Account.create(name: 'test', tenant: 'test', cname: 'test.lvh.me') }
      let(:mail) { described_class.contact(contact_form) }

      before do
        allow(Settings).to receive(:tenant_settings_filename).with('test').and_return(HykuAddons::Engine.root.join('spec', 'fixtures', 'settings', 'test-TEST.yml'))
        account.switch!
      end

      it "renders the body" do
        expect(mail.from).to eq "test@test.edu"
      end
    end
  end
end
