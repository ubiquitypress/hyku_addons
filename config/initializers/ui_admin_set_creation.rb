# frozen_string_literal: true

require_dependency "hyrax/search_state"

Hyrax::Admin::AdminSetsController.class_eval do
  def create_admin_set
    admin_set_create_service.call(admin_set: @admin_set, creating_user: nil)
  end
end
