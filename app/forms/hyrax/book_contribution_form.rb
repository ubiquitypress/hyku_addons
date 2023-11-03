# frozen_string_literal: true

module Hyrax
  class BookContributionForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:book_contribution)

    self.model_class = ::BookContribution
  end
end
