# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificNewsClipping`
module Hyrax
  # Generated form for PacificNewsClipping
  class PacificNewsClippingForm < Hyrax::Forms::WorkForm
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificNewsClipping
    add_terms %i[title alt_title resource_type creator contributor abstract
                 date_published challenged location outcome participant reading_level
                 photo_caption photo_description pagination is_included_in additional_links
                 rights_holder license doi subject keyword add_info]

    self.required_fields = %i[title creator resource_type institution]

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
