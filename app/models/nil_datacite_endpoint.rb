# frozen_string_literal: true
class NilDataCiteEndpoint < NilEndpoint
  def switch!
    Hyrax::DOI::DataCiteRegistrar.mode = nil
    Hyrax::DOI::DataCiteRegistrar.prefix = nil
    Hyrax::DOI::DataCiteRegistrar.username = nil
    Hyrax::DOI::DataCiteRegistrar.password = nil
    Rails.application.routes.default_url_options[:host] = nil
  end

  def mode
    nil
  end

  def prefix
    nil
  end

  def username
    nil
  end

  def password
    nil
  end

  def ping
    false
  end
end
