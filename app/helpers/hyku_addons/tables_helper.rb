# frozen_string_literal: true
module HykuAddons
  module TablesHelper
    # Generates a table for a collection of active record objects showing a list
    # of its attributes. The last column in the table will have a set of buttons
    # (edit, destroy and show). Pagination is at the top and at the bottom of the
    # table.
    #
    # @param [Array] collection A collection of ActiveRecord objects.
    # @param [Array] attr_list A list of the attributes to be shown.
    # @return [HTML] A table to show the paginated collection of objects.
    def table_for(collection, options = {}, *attr_list)
      show_actions = attr_list.delete_if { |attr| attr == :actions }
      classes = options[:classes] || ""
      model_class_name = options[:model_name] || collection.name
      table_id = options[:id] || model_class_name.tableize
      table_klazz = model_class_name.constantize
      table_headers = []

      attr_list.flatten.each do |attr_name|
        header_content = table_klazz.human_attribute_name(attr_name)
        header = content_tag(:th, header_content)
        table_headers << header
      end

      if show_actions
        table_headers << content_tag(:th, t('actions'), class: 'table_actions')
      end

      thead = content_tag :thead, content_tag(:tr, table_headers.join(" ").html_safe)
      tbody = content_tag :tbody, render(partial: options[:partial], collection: collection)
      table = content_tag(:table, "#{thead} #{tbody}".html_safe, id: table_id, class: "table table-hover #{classes}")

      table.html_safe
    end
  end
end
