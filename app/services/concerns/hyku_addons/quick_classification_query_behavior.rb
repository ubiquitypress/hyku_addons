module HykuAddons
  module QuickClassificationQueryBehavior
    extend ActiveSupport::Concern

    included do
      def normalized_model_names
        raise 'included'.inspect
        models.map { |name| concern_name_normalizer.call(name) if Site.first.available_works.include? name }
      end
    end

    def normalized_model_names
      raise 'fuck you work!'.inspect
      models.map { |name| concern_name_normalizer.call(name) if Site.first.available_works.include? name }
    end
  end
end
