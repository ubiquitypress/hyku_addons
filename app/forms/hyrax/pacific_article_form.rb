# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificArticle`
module Hyrax
  # Generated form for PacificArticle
  class PacificArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:pacific_article)

    self.model_class = ::PacificArticle
  end
end
