# frozen_string_literal: true

# Adjust controller for our needs
module HykuAddons
  module ProprietorControllerOverride
    extend ActiveSupport::Concern

    def update
      respond_to do |format|
        if @account.update(account_params)

          # handles updating of shared search tenant
          CreateSolrCollectionJob.perform_now(@account) if @account.shared_search_tenant?

          format.html { redirect_to [:proprietor, @account], notice: 'Account was successfully updated.' }
          format.json { render :show, status: :ok, location: [:proprietor, @account] }
        else
          format.html { render :edit }
          format.json { render json: @account.errors, status: :unprocessable_entity }
        end
      end
    end

    private

      # Never trust parameters from the scary internet, only allow the allowed list through.
      def account_params
        params.require(:account).permit(:name, :cname, :title,
                                        admin_emails: [],
                                        solr_endpoint_attributes: %i[id url],
                                        fcrepo_endpoint_attributes: %i[id url base_path],
                                        datacite_endpoint_attributes: %i[mode prefix username password],
                                        settings: [:file_size_limit, :locale_name, :shared_search, tenant_list: []])
      end
  end
end
