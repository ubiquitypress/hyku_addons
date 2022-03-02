# frozen_string_literal: true
module HykuAddons
  class RepositorySpaceService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("repository_space", model: model, locale: locale)
    end
  end
end
