# frozen_string_literal: true

module HykuAddons
  module AdminUserPresenterOverride
    extend ActiveSupport::Concern

    private

    # copied from Hyku main branch, we are currently on an older branch
    # https://github.com/samvera/hyku/blob/main/app/presenters/hyrax/admin/users_presenter.rb
    # Returns a list of users excluding the system users and guest_users
    def search
      ::User.registered.for_repository.without_system_accounts.uniq
    end
  end
end
