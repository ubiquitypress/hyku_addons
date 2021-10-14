# frozen_string_literal: true

module HykuAddons
  class SetWorkTenantUrl
    attr_accessor :account_cname, :url_type, :work

    # url_type is either  'shared_search' or oai_pmh
    def initialize(work_object, url_type)
      @account_cname = work_object&.work_tenant_cname
      @url_type = url_type
      @work = work_object
      work_type
    end

    def generate_url
      return nil if @account_cname.nil? || @work_type.nil?

      if @work_type == 'collections'
        set_collection_url
      else
        set_work_url
      end
    end

    private
      def work_type
        if @url_type == 'oai_pmh'
          prod_value = work&.human_readable_type&.downcase&.underscore&.pluralize
          generic_value = work.class&.name&.underscore&.pluralize   #&.to_model&.model_name&.singular

          @work_type = Rails.env.production? ? prod_value : generic_value
        elsif @url_type == 'shared_search'
          @work_type = generic_value
        end
      end

      def set_collection_url
        if (account_cname.split('.') & ['hyku', 'docker']).any?
          "http://#{@account_cname}:3000/#{@work_type}/#{work.id}?locale=en"
        else
          "https://#{@account_cname}/#{work_type}/#{work.id}?locale=en"
         end
       end

      def set_work_url
        if (account_cname.split('.') & ['hyku', 'docker']).any?
          "http://#{@account_cname}:3000/concern/#{@work_type}/#{work.id}"
        else
          production_url
        end
      end

      def production_url
        if @url_type == 'oai_pmh'
          "https://#{@account_cname}/#{@work_type}/#{work.id}"
        elsif @url_type == 'shared_search'
          "https://#{@account_cname}/concern#{@work_type}/#{work.id}"
        end
      end
  end
end
