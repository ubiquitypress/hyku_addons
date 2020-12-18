# frozen_string_literal: true
module HykuAddons
  module AccountControllerBehavior
    extend ActiveSupport::Concern

    included do
      before_action :merge_settings_for_update, only: [:update]
    end

    private

      def merge_settings_for_update
        return unless account_params['settings'].present?
        @account.settings.merge!(account_params['settings'])
        @account.settings.compact!
        params['account'].delete('settings')
      end
  end
end
