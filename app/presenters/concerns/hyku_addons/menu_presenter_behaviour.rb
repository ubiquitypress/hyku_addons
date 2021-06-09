module HykuAddons
  module MenuPresenterBehaviour
    extend ActiveSupport::Concern

    included do
      include HykuAddons::ContentHelper
    end

    def menu_item_for(options)
      name = options[:name].presence || ""
      path = options[:path].presence || "admin_#{name.downcase}_path"
      icon = options[:icon].presence || name

      nav_link(path, options) do
        [
          icon(icon),
          content_tag(:span, I18n.t(name), class: "sidebar-action-text")
        ].join.html_safe
      end
    end
  end
end