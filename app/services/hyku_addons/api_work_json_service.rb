# frozen_string_literal: true

module HykuAddons
  class ApiWorkJsonService
    attr_reader :work

    ##
    # @param [Work]
    def initialize(account, work_id)
      @account = account
      @work_id = work_id
      @service_base_path = @account.settings["bulkrax_imports_server"]
      @import_tenant_id = '3ac7fcf1-2ed3-4e47-aebd-93f10b55fe0a'
      @username = 'elisa.barrett@ubiquitypress.com'
      @password = 'Ubiquity'
    end

    # @return [Hash] work json info
    def fetch
      uri = URI("#{@service_base_path}/api/v1/tenant/#{@import_tenant_id}/work/#{@work_id}.json")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.instance_of? URI::HTTPS
      req = Net::HTTP::Get.new(uri)
      req["Cookie"] = auth_token_cookie
      res = http.request(req)
      res.is_a?(Net::HTTPSuccess) ? JSON.parse(res.body.presence || "{}") : {}
    end

    def auth_token_cookie
      @_auth_token_cookie ||= lambda {
        uri = URI("#{@service_base_path}/api/v1/tenant/#{@import_tenant_id}/users/login")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.instance_of? URI::HTTPS
        req = Net::HTTP::Post.new(uri)
        req.set_form_data(email: @username, password: @password)
        resp = http.request(req)
        resp.header['set-cookie'].split(', ')[1].split("\; ")[0]
      }.call
    end
  end
end
