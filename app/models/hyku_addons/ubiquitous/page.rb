module HykuAddons
  module Ubiquitous
    class Page < ApplicationRecord
      has_many :hyku_widgets

      validates :name, :path_matcher,
                presence: true
      validates :grid_columns_count,
                numericality: {
                  only_integer: true,
                  greater_than_or_equal_to: 1,
                  less_than_or_equal_to: 4
                }
    end
  end
end
