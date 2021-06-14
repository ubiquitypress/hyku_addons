# frozen_string_literal: true

module Hyrax
  module Orcid
    class WorksController < ::ApplicationController
      include Hyrax::WorksControllerBehavior
      include Hyrax::Orcid::UrlHelper

      def accept

      end
    end
  end
end

