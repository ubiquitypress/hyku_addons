# frozen_string_literal: true

module Hyrax
  class EslnArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:esln_article)

    self.model_class = ::EslnArticle
  end
end
