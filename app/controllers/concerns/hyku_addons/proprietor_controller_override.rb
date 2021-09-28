# frozen_string_literal: true

# Adjust controller for our needs
module HykuAddons
  module ProprietorControllerOverride
    extend ActiveSupport::Concern

    def update
      respond_to do |format|
        if @account.update(account_params)

          # handles updating of shared search tenant
          f = account_params['full_account_cross_searches_attributes'].to_h
          CreateSolrCollectionJob.perform_now(@account) if deleted_or_new(f)

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
        params.require(:account).permit(:name, :cname, :title, :search_only,
                                        admin_emails: [],
                                        solr_endpoint_attributes: %i[id url],
                                        fcrepo_endpoint_attributes: %i[id url base_path],
                                        datacite_endpoint_attributes: %i[mode prefix username password],
                                        settings: [:file_size_limit, :locale_name],
                                        full_account_cross_searches_attributes: [:id, :_destroy, :full_account_id, full_account_attributes: [:id]])
      end

      def deleted_or_new(hash)
        hash.detect do |_k, v|
          ActiveModel::Type::Boolean.new.cast(v["_destroy"]) == true || v["id"].blank?
        end
      end
  end
end
