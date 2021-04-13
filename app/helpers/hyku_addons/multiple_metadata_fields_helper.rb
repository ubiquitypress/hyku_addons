# frozen_string_literal: true
module HykuAddons
  module MultipleMetadataFieldsHelper
    def get_model(presenter_record, _model_class, _field, multipart_sort_field_name = nil)
      # model ||= model_class.constantize.new

      # If the value of the first is record is nil return the model
      # @value =   get_json_data || model
      @value = presenter_record.first

      return nil unless valid_json?(@value)
      array_of_hash ||= JSON.parse(@value)
      return [model.attributes] if array_of_hash.first.class == String || array_of_hash.first.nil?

      # return sort_hash(array_of_hash, multipart_sort_field_name) if multipart_sort_field_name
      return sort_hash(array_of_hash, multipart_sort_field_name) if multipart_sort_field_name

      array_of_hash
    end

    # leave it as a public method because it used in other files
    # return false if json == String
    def valid_json?(data)
      return false unless data.is_a? String
      JSON.parse(data)
      true
    rescue JSON::ParserError
      false
    end

    # TODO: This seems like a terrible way of determining which models should
    # be using this presenter when we have a static list on each presenter
    def check_has_editor_fields?(presenter)
      ["Book", "BookContribution", "ConferenceItem", "Report", "GenericWork"].include? presenter
    end
  end
end
