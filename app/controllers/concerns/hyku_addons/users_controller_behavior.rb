# frozen_string_literal: true

# Overrides Hyku API user show method to allow users to take into account of added setting
module HykuAddons
  module UsersControllerBehavior
    extend ActiveSupport::Concern

    def index
      @users = User.with_public_profile
      @user_count = @users.count
    end

    def show
      @user = User.with_public_profile.find_by(email: params[:email])

      return render json: { status: 403, code: "forbidden", message: t("errors.users_forbidden") } if @user.blank?

      query_string = "(generic_type_sim:Work AND creator_tesim:\"*#{@user.email}*\") AND visibility_ssi:open"
      user_document_id_list = ActiveFedora::SolrService.get(query_string, rows: 1_000_000).dig("response", "docs").pluck("id")
      @user_works = Hyrax::PresenterFactory.build_for(ids: user_document_id_list,
                                                      presenter_class: Hyku::WorkShowPresenter,
                                                      presenter_args: current_ability)
      collection_search_builder = Hyrax::CollectionSearchBuilder.new(self).with_access(:read).rows(1_000_000)
      @collection_docs = repository.search(collection_search_builder).documents
    end
  end
end
