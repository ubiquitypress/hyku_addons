# frozen_string_literal: true
module HykuAddons
  class CurrentHeInstitutionService < HykuAddons::QaSelectService
    def initialize(model: nil, request: nil)
      super('current_he_institution', model: model, request: request)
    end

    def select_active_options_isni
      select_active_options.map { |e| authority.find(e[1])[:isni] }
    end

    def select_active_options_ror
      select_active_options.map { |e| authority.find(e[1])[:ror] }
    end
  end
end
