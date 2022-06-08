# frozen_string_literal: true

module Hyrax
  class LtuArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ltu_article)

    self.model_class = ::LtuArticle
  end
end
