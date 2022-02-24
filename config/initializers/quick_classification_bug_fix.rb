# frozen_string_literal: true
# NOTE: This issue only seems to present in development, and not consistently.
# Compact the available work types to remove `nil` and prevent an `Nil location provided. Can't build URI.` error
# when not all options are selected, thrown from `SelectTypePresenter#switch_to_new_work_path`
Hyrax::QuickClassificationQuery.class_eval do
  def normalized_model_names
    models.map { |name| concern_name_normalizer.call(name) if Site.first.available_works.include?(name) }.compact
  end
end
