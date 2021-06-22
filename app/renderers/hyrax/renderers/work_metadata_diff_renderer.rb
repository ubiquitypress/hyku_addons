# frozen_string_literal: true

module Hyrax
  module Renderers
    class WorkMetadataDiffRenderer < AttributeRenderer
      def initialize(entry, view_context)
        @entry = entry
        @view_context = view_context
      end

      # Draw the list with the diffs
      def render_diff
        if service.validate
          @view_context.content_tag :p, "No validation issues detected"
        else
          render_validation_issues(Array.wrap(service.errors))
        end
      end

      def render_diff_from_local_status
        validation_errors = @entry.current_status.error_backtrace
        if validation_errors.blank?
          @view_context.content_tag :p, "No validation issues detected"
        else
          render_validation_issues(validation_errors)
        end
      end

      def render_source_metadata
        key_value_list_for(service.source_metadata)
      end

      def render_destination_metadata
        key_value_list_for(service.destination_metadata)
      end

      def render_source_metadata_after_transform
        key_value_list_for(service.source_metadata_after_transforms)
      end

      def render_destination_metadata_after_transform
        key_value_list_for(service.destination_metadata_after_transforms)
      end

      protected

        def service
          @_service ||= HykuAddons::Validations::EntryValidationService.new(@view_context.current_account, @entry)
        end

        def key_value_list_for(a_hash)
          a_hash.sort_by { |key| key }.to_h.map do |k, v|
            @view_context.content_tag :p do
              @view_context.content_tag(:strong, "#{k}: ") + v.to_s
            end
          end.join.html_safe
        end

        def render_validation_issues(validation_errors)
          @view_context.content_tag :table, class: 'table' do
            thead = validation_table_header
            tbody = @view_context.content_tag :tbody do
              validation_errors.sort_by { |error| error[:path] }.map do |diff_entry|
                diff_entry_html(diff_entry.with_indifferent_access)
              end.join.html_safe
            end
            [thead, tbody].join.html_safe
          end
        end

        def validation_table_header
          @view_context.content_tag :thead do
            @view_context.content_tag(:tr) do
              [
                @view_context.content_tag(:th, I18n.t("bulkrax.validation_issues.attribute")),
                @view_context.content_tag(:th, I18n.t("bulkrax.validation_issues.original_value")),
                @view_context.content_tag(:th, I18n.t("bulkrax.validation_issues.current_value"))
              ].join.html_safe
            end
          end
        end

        def diff_entry_html(diff_entry)
          label_klazz = case diff_entry[:op]&.to_s
                        when 'add'
                          'success'
                        when 'move'
                          'info'
                        when 'remove'
                          'danger'
                        else 'info'
                        end
          @view_context.content_tag :tr, class: "bg-#{label_klazz} overflow-wrap-break" do
            diff_entry_item(diff_entry[:path], diff_entry[:source_v], diff_entry[:dest_v])
          end
        end

        def diff_entry_item(path, from, to)
          [
            @view_context.content_tag(:td, path, class: ""),
            @view_context.content_tag(:td, from, class: "bg-none"),
            @view_context.content_tag(:td, to, class: "bg-none")
          ].join.html_safe
        end
    end
  end
end
