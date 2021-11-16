# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mailboxer::MessageMailer, clean: true, multitenant: true do
  let(:account) do
    Account.create(name: "test", cname: "test.lvh.me", locale_name: "test")
  end
  let(:user) { create :user }

  describe "new_message_email" do
    context "with a message to notify" do
      let(:mailboxer_message) { Mailboxer::Message.new(body: "Hello", sender: user) }
      let(:mail) { described_class.new_message_email(mailboxer_message, user) }

      before do
        allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
          block&.call
        end

        Apartment::Tenant.switch!(account.tenant) do
          Site.update(account: account, application_name: account.name)
          mail
        end
      end

      it "replaces the email headers" do
        expect(mail.subject).to include(Site.instance.application_name)
      end

      it "sends the email" do
        expect { mail.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
