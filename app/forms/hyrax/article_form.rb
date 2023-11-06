# frozen_string_literal: true

module Hyrax
  class ArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:article)

    self.model_class = ::Article
  end
end
