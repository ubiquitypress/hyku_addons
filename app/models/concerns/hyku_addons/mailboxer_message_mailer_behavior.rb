# frozen_string_literal: true

module HykuAddons
  module MailboxerMessageMailerBehavior
    extend ActiveSupport::Concern

    def new_message_email(message, receiver)
      @message  = message
      @receiver = receiver

      message_email("mailboxer.message_mailer.subject_new", "hyku_addons_new_message_email")
    end

    # Sends an email for indicating a reply in an already created conversation
    def reply_message_email(message, receiver)
      @message  = message
      @receiver = receiver

      message_email("mailboxer.message_mailer.subject_reply", "hyku_addons_reply_message_email")
    end

    protected

      def message_email(subject_key, template)
        set_subject(@message)

        mail to: receiver.send(Mailboxer.email_method, @message),
             subject: t(subject_key, subject: @subject, tenant_name: Site.instance.application_name),
             template_name: template
      end
  end
end
