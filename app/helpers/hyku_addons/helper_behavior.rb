# frozen_string_literal: true

module HykuAddons
  module HelperBehavior
    include HykuAddons::MultipleMetadataFieldsHelper
    include HykuAddons::CreatorFieldHelper
    include HykuAddons::ContributorFieldHelper
    include HykuAddons::RelatedIdentifierHelper
    include HykuAddons::SimplifiedAdminSetSelectionWorkFormHelper
    include HykuAddons::NotesTabFormHelper
    include HykuAddons::OrcidHelperBehavior
    include HykuAddons::CrossTenantSharedSearchHelper
    include HykuAddons::ApiDateHelper

    def account_setting_title(setting_name)
      title_key = "settings.titles.#{setting_name}"

      I18n.exists?(title_key) ? t(title_key) : setting_name.to_s.humanize
    end
  end
end
