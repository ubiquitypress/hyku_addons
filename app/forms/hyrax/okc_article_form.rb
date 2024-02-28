# frozen_string_literal: true

module Hyrax
  class OkcArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:okc_article)

    self.model_class = ::OkcArticle
  end
end
