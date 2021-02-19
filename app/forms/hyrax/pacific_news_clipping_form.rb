# frozen_string_literal: true
module Hyrax
  class PacificNewsClippingForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificNewsClipping
    add_terms %i[title alt_title resource_type creator contributor abstract
                 date_published challenged location outcome participant reading_level
                 photo_caption photo_description pagination is_included_in additional_links
                 rights_holder license doi subject keyword add_info]
    self.terms -= %i[language rights_statement]
    self.required_fields = %i[title creator resource_type]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :creator, :contributor, :date_published,
                             :challenged, :location, :outcome, :participant, :reading_level,
                             :photo_caption, :photo_description, :pagination, :is_included_in,
                             :additional_links, :subject, :keyword]
      end
    end
  end
end
