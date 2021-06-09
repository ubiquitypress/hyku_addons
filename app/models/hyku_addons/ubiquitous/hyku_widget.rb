module HykuAddons
  module Ubiquitous
    class HykuWidget < Widget
      belongs_to :page, required: true, touch: true

      def position
        (super || 0) + 1
      end

      def position=(val)
        super(val.to_i - 1) if val
      end
    end
  end
end
