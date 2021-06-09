module HykuAddons
  module Ubiquitous
    class Container < ApplicationRecord
      belongs_to :content, required: true
      has_many :widgets

      enum style: { one_col_text: 0, two_col_text: 1 }
    end
  end
end
