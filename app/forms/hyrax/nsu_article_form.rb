# frozen_string_literal: true
module Hyrax
  class NsuArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:nsu_article)

    self.model_class = ::NsuArticle
  end
end
