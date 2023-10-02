# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsArticle`
module Hyrax
  # Generated form for RedlandsArticle
  class RedlandsArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:redlands_article)

    self.model_class = ::RedlandsArticle
  end
end
