# frozen_string_literal: true

module Hyrax
  class BcArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:bc_article)

    self.model_class = ::BcArticle
  end
end
