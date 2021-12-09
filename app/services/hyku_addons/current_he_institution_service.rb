# frozen_string_literal: true

module HykuAddons
  class CurrentHeInstitutionService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super("current_he_institution", model: model)
    end

    def select_active_options_isni
      quick_active_elements.map { |a| a["isni"] }
    end

    def select_active_options_ror
      quick_active_elements.map { |a| a["ror"] }
    end

    protected

      # This method accesses a private method on the authority which returns the raw yaml data as an array of hashes
      # without removing elements. This means we can increase the speed with which we get different sets of keys
      def quick_active_elements
        authority.send(:terms).select { |a| a["active"] == true }
      end
  end
end
