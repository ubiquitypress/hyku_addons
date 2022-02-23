# frozen_string_literal: true
module HykuAddons
  class RepositorySpaceService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super("repository_space", model: model)
    end
  end
end
