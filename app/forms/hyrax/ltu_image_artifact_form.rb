# frozen_string_literal: true

module Hyrax
  class LtuImageArtifactForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ltu_image_artifact)

    self.model_class = ::LtuImageArtifact
  end
end
