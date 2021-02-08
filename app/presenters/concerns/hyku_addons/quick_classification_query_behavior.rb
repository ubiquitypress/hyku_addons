module HykuAddons
  module QuickClassificationQueryBehavior
    extend ActiveSupport::Concern

    def authorized_models
      super.compact
    end
  end
end
