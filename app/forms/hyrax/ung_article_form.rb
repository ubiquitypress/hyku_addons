# frozen_string_literal: true

module Hyrax
  class UngArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ung_article)

    self.model_class = ::UngArticle
  end
end
