module HykuAddons
  module Admin
    module Ubiquitous
      module ContainersHelper
        def available_container_styles_collection
          HykuAddons::Ubiquitous::Container.styles.map { |k, v| [t("enums.ubiquitous.container.styles.#{k}"), k] }
        end
      end
    end
  end
end