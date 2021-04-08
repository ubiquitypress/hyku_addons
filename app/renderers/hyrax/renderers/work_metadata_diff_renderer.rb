# frozen_string_literal: true

require 'json-diff'

module Hyrax
  module Renderers
    class WorkMetadataDiffRenderer < AttributeRenderer
      def initialize(entry, view_context)
        @entry = entry
        @view_context = view_context
        @service = HykuAddons::EntryValidationService.new()
      end

      # Draw the list with the diffs
      def render_diff
        if @service.validate(@entry)
          @view_context.content_tag :p, "No validation issues detected"
        else
          @view_context.content_tag :ul do
            Array.wrap(@service.errors).sort_by { |error| error["path"] }.map do |diff_entry|
              diff_entry_html(diff_entry.with_indifferent_access)
            end.join.html_safe
          end
        end
      end

      def render_source_metadata
        key_value_list_for(@service.source_metadata(@entry))
      end

      def render_destination_metadata
        key_value_list_for(@service.destination_metadata(@entry))
      end

      protected

      def key_value_list_for(a_hash)
        a_hash.sort_by { |key| key }.to_h.map do |k, v|
          @view_context.content_tag :p do
            @view_context.content_tag(:strong, "#{k}: ") + v.to_s
          end
        end.join.html_safe
      end

      def diff_entry_html(diff_entry)
        @view_context.content_tag :li do
          change_description = "#{diff_entry[:path]}: #{diff_entry[:value]}"
          label_klazz = case diff_entry[:op]
                        when 'add';'success'
                        when 'move'
                          'info'
                        when 'remove'
                          'danger'
                        else
                          'warning'
                        end
          @view_context.content_tag :span, change_description, class: "label label-#{label_klazz}"
        end
      end
    end
  end
end
