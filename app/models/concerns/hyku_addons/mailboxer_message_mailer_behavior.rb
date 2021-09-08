# frozen_string_literal: true

module HykuAddons
  module MailboxerMessageMailerBehavior
    extend ActiveSupport::Concern

    def new_message_email(message, receiver)
      @message  = message
      @receiver = receiver
      set_subject(message)
      mail to: receiver.send(Mailboxer.email_method, message),
           subject: t('mailboxer.message_mailer.subject_new', subject: @subject, tenant_name: Site.instance.application_name),
           template_name: 'hyku_addons_new_message_email'
    end

    # Sends an email for indicating a reply in an already created conversation
    def reply_message_email(message, receiver)
      @message  = message
      @receiver = receiver
      set_subject(message)
      mail to: receiver.send(Mailboxer.email_method, message),
           subject: t('mailboxer.message_mailer.subject_reply', subject: @subject, tenant_name: Site.instance.application_name),
           template_name: 'hyku_addons_reply_message_email'
    end
  end
end
