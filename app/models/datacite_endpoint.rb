# frozen_string_literal: true

class DataCiteEndpoint < ::Endpoint
  store :options, accessors: %i[mode prefix username password]

  def switch!
    Hyrax::DOI::DataCiteRegistrar.mode = mode
    Hyrax::DOI::DataCiteRegistrar.prefix = prefix
    Hyrax::DOI::DataCiteRegistrar.username = username
    Hyrax::DOI::DataCiteRegistrar.password = password
  end

  # Remove the solr collection then destroy this record
  def remove!
    destroy
  end

  def self.reset!
    Hyrax::DOI::DataCiteRegistrar.mode = nil
    Hyrax::DOI::DataCiteRegistrar.prefix = nil
    Hyrax::DOI::DataCiteRegistrar.username = nil
    Hyrax::DOI::DataCiteRegistrar.password = nil
  end

  def ping
    # TODO: ping https://api.test.datacite.org/heartbeat or some other endpoint
    true
  end
end
