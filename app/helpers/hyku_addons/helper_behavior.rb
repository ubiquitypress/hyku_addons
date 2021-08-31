# frozen_string_literal: true
#
module HykuAddons
  module HelperBehavior
    include HykuAddons::MultipleMetadataFieldsHelper
    include HykuAddons::CreatorFieldHelper
    include HykuAddons::ContributorFieldHelper
    include HykuAddons::SimplifiedAdminSetSelectionWorkFormHelper
    include HykuAddons::SimplifiedDepositFormHelper
    include HykuAddons::NotesTabFormHelper
  end
end
