# frozen_string_literal: true

module HykuAddons
  module Validations
    class EntryValidationService
      attr_reader :errors, :entry

      EXCLUDED_FIELDS = %i[].freeze
      RENAMED_FIELDS = {}.freeze
      EXCLUDED_FIELDS_WITH_VALUES = {}.freeze

      def initialize(account, entry)
        @account = account
        @entry = entry

        raise ArgumentError, "You must pass a valid Account" unless @account.present?
        raise ArgumentError, "You must pass a valid HykuAddons::CsvEntry with  successfully imported items" unless @entry&.status == "Complete"
      end

      def validate
        Rails.logger.info "Validating entry #{@entry.id}"
        @errors = left_differences + right_differences + merged_fields_differences
        return true if @errors.empty?

        @entry.current_status.update(error_backtrace: @errors)
        false
      end

      def source_metadata
        @_source_metadata ||= @entry.raw_metadata
      end

      def destination_metadata
        @_destination_metadata ||= ActiveFedora::SolrService.get("id:#{@entry.identifier}").dig('response', 'docs')&.first || {}
      end

      def source_metadata_after_transforms
        filtered = processable_fields(source_metadata)
        filtered_and_renamed = rename_fields(filtered)
        reevaluate_fields(filtered_and_renamed)
      end

      def destination_metadata_after_transforms
        reevaluate_fields(processable_fields(destination_metadata))
      end

      def left_differences
        differences = source_metadata_after_transforms.keep_if { |k, v| v.present? && !destination_metadata_after_transforms.key?(k) }
        diff_list_for(differences, :remove)
      end

      def right_differences
        differences = destination_metadata_after_transforms.keep_if { |k, _v| !source_metadata_after_transforms.key?(k) }
        diff_list_for(differences, :add)
      end

      def merged_fields_differences
        differences = destination_metadata_after_transforms.keep_if do |k, v|
          value_at_source = source_metadata_after_transforms[k]
          if value_at_source.present?
            begin
              semantic_comparison(JSON.parse(value_at_source[0]), JSON.parse(v[0]))
            rescue
              value_at_source.present? && semantic_comparison(value_at_source, v)
            end
          end
        end
        diff_list_for(differences, :change)
      end

      protected

        # Returns a Hash that represents a validation issue in a similar way of the Diff format:
        # Fields:
        # - path: name of the attribute having a difference
        # - op: type of difference (add, remove or change)
        # - source_v: Value of metadata on source
        # - dest_v: Value of metadata on destination
        # - t_source_v: Value of metadata on source after transforms
        # - t_dest_v: Value of metadata on destination after transforms
        def diff_list_for(issues, operation)
          issues.map do |k, _v|
            {
              path: k,
              op: operation,
              source_v: source_metadata[k],
              dest_v: destination_metadata[k],
              t_source_v: source_metadata_after_transforms[k],
              t_dest_v: destination_metadata_after_transforms[k]
            }
          end
        end

        def processable_fields(metadata)
          metadata.select do |k, v|
            !excluded_field?(k) && !excluded_field_with_value?(k, v) && non_empty_list_of_values?(v)
          end
        end

        def excluded_field?(k)
          EXCLUDED_FIELDS.include?(k.to_sym)
        end

        def excluded_field_with_value?(k, v)
          Array(EXCLUDED_FIELDS_WITH_VALUES[k]) == Array(v)
        end

        def non_empty_list_of_values?(v)
          Array.wrap(v).any?(&:present?)
        end

        def rename_fields(metadata)
          RENAMED_FIELDS.each do |k, v|
            metadata[v] = metadata.delete(k)
          end
          metadata
        end

        def semantic_comparison(a, b)
          non_blank_stripped_sets(a) != non_blank_stripped_sets(b)
        end

        def non_blank_stripped_sets(item)
          Array.wrap(item).select(&:present?).map { |i| i.try(:strip)&.downcase || i }.to_set
        end

        def reevaluate_fields(metadata)
          metadata.clone.each do |k, v|
            reeval_method_name = "reevaluate_#{k}"
            next unless methods.include?(reeval_method_name.to_sym) && v.try(:any?)

            new_value = send(reeval_method_name, v)
            metadata[k] = new_value
          end
          metadata
        end
    end
  end
end
