# frozen_string_literal: true
# Use this with Bolognese like the following:
#
# json = Hyrax::GenericWorkPresenter::DELEGATED_METHODS.collect { |m|
#   [m, p.send(m)]
# }.to_h.merge("has_model" => p.model.model_name).to_json
# Bolognese::Readers::GenericWorkReader.new(input: json, from: "generic_work")
#
# Then crosswalk it with:
# m.datacite
# Or:
# m.ris
module Bolognese
  module Readers
    class GenericWorkReader < BaseWorkReader
    end
  end
end
