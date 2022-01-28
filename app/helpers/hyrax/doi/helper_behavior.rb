# frozen_string_literal: true

module Hyrax
  module DOI
    module HelperBehavior
      # Override the Hyrax-DOI class to prevent creation of DOI tab
      include Hyrax::DOI::WorkShowHelper
    end
  end
end
