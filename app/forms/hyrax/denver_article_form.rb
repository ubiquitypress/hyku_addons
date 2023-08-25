# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverArticle`
module Hyrax
  # Generated form for DenverArticle
  class DenverArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:denver_article)

    self.model_class = ::DenverArticle
  end
end
