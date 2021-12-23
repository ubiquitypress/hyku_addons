# frozen_string_literal: true
module HykuAddons
  module ProfilesControllerBehavior
    extend ActiveSupport::Concern

    private

      def user_params
        params.require(:user).permit(:avatar, :twitter_handle, :linkedin_handle,
                                     :remove_avatar, :orcid, :display_profile,
                                     :display_name, :department, :biography, :telephone,
                                     :website)
      end
  end
end
