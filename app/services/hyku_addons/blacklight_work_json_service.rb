# frozen_string_literal: true

module HykuAddons
  class BlacklightWorkJsonService
    attr_reader :work

    ##
    # @param [Work]
    def initialize(service_base_path, username, password)
      @service_base_path = service_base_path
      @username = username
      @password = password
    end

    # @return [Hash] work json info
    def fetch(entry)
      uri = URI("#{@service_base_path}/catalog/#{entry.identifier}.json")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.instance_of? URI::HTTPS
      req = Net::HTTP::Get.new(uri)
      req.basic_auth(@username, @password)
      res = http.request(req)
      Rails.logger.debug "BlacklightWorkJsonService for #{uri} -> #{res}"
      res.is_a?(Net::HTTPSuccess) ? JSON.parse(res.body) : {}
    end
  end
end
