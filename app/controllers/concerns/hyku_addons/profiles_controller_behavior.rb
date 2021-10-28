# frozen_string_literal: true
module HykuAddons
  module ProfilesControllerBehavior
    extend ActiveSupport::Concern

    private

    def user_params
      params.require(:user).permit(:avatar, :facebook_handle, :twitter_handle,
                                   :googleplus_handle, :linkedin_handle, :remove_avatar,
                                   :orcid, :display_profile, :given_name, :family_name,
                                   :middle_names)
    end
  end
end
