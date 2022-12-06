# frozen_string_literal: true
module Hyrax
  class UnaArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:una_article)

    self.model_class = ::UnaArticle
  end
end
