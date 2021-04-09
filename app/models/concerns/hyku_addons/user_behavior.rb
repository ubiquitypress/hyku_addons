# frozen_string_literal: true

module HykuAddons
  module UserBehavior
    extend ActiveSupport::Concern

    included do
      has_one :orcid_authorization, class_name: "UserOrcidAuthorization"
    end
  end
end
