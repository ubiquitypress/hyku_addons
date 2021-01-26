# frozen_string_literal: true
module HykuAddons
  class CsvMatcher < Bulkrax::CsvMatcher
    def parse_date_published(src)
      date_parts = src.split('-')
      date_hash = { 'date_published_year' => date_parts[0] }
      date_hash['date_published_month'] = date_parts[1] if date_parts[1].present?
      date_hash['date_published_day'] = date_parts[2] if date_parts[2].present?
      date_hash
    end

    # Only add valid resource types
    def parse_resource_type(src)
      HykuAddons::ResourceTypesService.new.label(src.to_s.strip.titleize)
    rescue KeyError
      nil
    end

    # TODO: Repeat this for other authority fields?
  end
end
