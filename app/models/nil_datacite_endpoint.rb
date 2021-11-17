# frozen_string_literal: true
class NilDataCiteEndpoint < NilEndpoint
  def switch!
    Hyrax::DOI::DataCiteRegistrar.mode = :test
    Hyrax::DOI::DataCiteRegistrar.prefix = nil
    Hyrax::DOI::DataCiteRegistrar.username = nil
    Hyrax::DOI::DataCiteRegistrar.password = nil
  end

  def mode
    :test
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
