# Generated via
#  `rails generate hyrax:work UvaWork`
module Hyrax
  # Generated form for UvaWork
  class UvaWorkForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::UvaWork
    add_terms %i[title resource_type creator abstract license keyword contributor language
                 publisher date_published related_url funder add_info ]
    self.terms -= %i[rights_statement subject]
    self.required_fields = %i[title creator resource_type abstract licence publisher]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:publisher, :keyword]
      end
    end
  end
end
