module HykuAddons
  module Dashboard
    module ProfilesControllerBehavior
      def show
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.profile'), hyrax.dashboard_profile_path

        @presenter = Hyrax::UserProfilePresenter.new(@user, current_ability)
      end
    end
  end
end
