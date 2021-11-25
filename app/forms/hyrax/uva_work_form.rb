# frozen_string_literal: true

module Hyrax
  class UvaWorkForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:uva_work)

    self.model_class = ::UvaWork
  end
end
