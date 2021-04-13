# frozen_string_literal: true

module HykuAddons
  class BlacklightWorkJsonCookieService
    attr_reader :work

    ##
    # @param [Work]
    def initialize(service_base_path, cookie)
      @service_base_path = service_base_path
      @cookie = cookie
    end

    # @return [Hash] work json info
    def fetch(entry)
      uri = URI("#{@service_base_path}/catalog/#{entry.identifier}.json")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.instance_of? URI::HTTPS
      req = Net::HTTP::Get.new(uri)
      req["Cookie"] = @cookie
      res = http.request(req)
      Rails.logger.debug "BlacklightWorkJsonCookieService for #{uri} -> #{res}"
      res.is_a?(Net::HTTPSuccess) ? JSON.parse(res.body) : {}
    end
  end
end
