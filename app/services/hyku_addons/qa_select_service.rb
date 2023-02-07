# frozen_string_literal: true
module HykuAddons
  class QaSelectService < Hyrax::QaSelectService
    # model - CurationConcern model
    def initialize(authority_name, model: nil, locale: nil)
      @authority_name = authority_name
      @model = model
      @locale = locale

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
      prepare([@authority_name, tenant_locale])
    end

    def model_authority_name
      prepare([@authority_name, model_name])
    end

    def model_tenant_authority_name
      prepare([@authority_name, model_name, tenant_locale])
    end

    def model_name
      @model_name ||= @model&.name&.underscore&.upcase
    end

    def tenant_locale
      @tenant_locale ||= (@locale || account_locale).to_s.upcase
    end

    def account_locale
      account&.settings&.dig("locale_name").presence || account&.name
    end

    def account
      Site.instance&.account
    end

    def prepare(array)
      array.reject(&:blank?).join("-")
    end
  end
end
