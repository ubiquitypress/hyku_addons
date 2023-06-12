# frozen_string_literal: true
module HykuAddons
  module WorksControllerBehavior
    extend ActiveSupport::Concern

    included do
      include HykuAddons::WorksControllerAdditionalMimeTypesBehavior
      # Add other includes here
    end
  end
end
