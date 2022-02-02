# frozen_string_literal: true

module HykuAddons
  module DOIFormBehavior
    def primary_terms
      super + [:doi]
    end
  end
end
