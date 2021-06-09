# frozen_string_literal: true
module HykuAddons
  module ContentHelper
    def icon(name, style = "fa", options = {})
      icon_class = "#{style} fa-#{name}"

      content_tag(:i, nil, options.merge(class: "#{icon_class} #{options[:class]}"))
    end

    def content_with_icon(content, klazz, color = nil, options = {})
      [icon(klazz, color, options), content].join(" ").html_safe
    end

    # Provides a link styled as a button.
    #
    # @param [String] anchor The anchor for the link
    # @param [String] url The address to link to
    # @param [Hash] options The options for link_to
    # @return [String] the link with the needed styles
    def button_link_to(anchor, url, options = {})
      klazz = options.delete(:class)

      if klazz.present?
        options[:class] = "btn #{klazz}"
      else
        options[:class] = "btn"
      end

      link_to(anchor, url, options)
    end

    def link_to_new(text = nil, path = nil, options = {})
      text ||= t("actions.new")
      path ||= url_for(action: :new)

      button_link_to(content_with_icon(text, 'plus'), path, options.merge(class: "btn-primary"))
    end

    def link_to_back
      button_link_to(content_with_icon('Back', "undo"), :back, target: '_blank', class: 'btn-primary no-print')
    end

    def link_to_destroy_item(path, opts = {})
      link_to(icon('trash'), path, opts.merge(method: :delete, class: 'fa-lg destroy-action',
              data: { confirm: t('destroy_action.confirm.message') }))
    end
  end
end
