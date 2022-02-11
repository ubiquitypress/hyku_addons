# frozen_string_literal: true
module HykuAddons
  class QaSelectService < Hyrax::QaSelectService
    # model - CurationConcern model
    def initialize(authority_name, model: nil)
      @authority_name = authority_name
      @model = model

      # Search for authority with the following precedence:
      # authority_name-MODEL_NAME-TENANT-NAME
      # authority_name-MODEL_NAME
      # authority_name-TENANT-NAME
      # authority_name
      if Qa::Authorities::Local.subauthorities.include?(model_tenant_authority_name)
        super(model_tenant_authority_name)
      elsif Qa::Authorities::Local.subauthorities.include?(model_authority_name)
        super(model_authority_name)
      elsif Qa::Authorities::Local.subauthorities.include?(tenant_authority_name)
        super(tenant_authority_name)
      else
        super(authority_name)
      end
    end

    private

      def tenant_authority_name
        [@authority_name, tenant_locale].compact.join("-")
      end

      def model_authority_name
        [@authority_name, model_name].compact.join("-")
      end

      def model_tenant_authority_name
        [@authority_name, model_name, tenant_locale].compact.join("-")
      end

      def model_name
        @model_name ||= @model&.name&.underscore&.upcase
      end

      def tenant_locale
        @tenant_locale ||= begin
          return unless (account = Site.instance&.account)

          locale_name = account.settings&.dig("locale_name").presence || account.name

          locale_name&.upcase
        end
      end
  end
end
