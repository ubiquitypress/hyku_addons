# frozen_string_literal: true

module HykuAddons
  module Bulkrax
    module ObjectFactoryBehavior
      def run
        arg_hash = { id: attributes[:id], name: "UPDATE", klass: klass }
        @object = find

        if object
          object.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX if object.respond_to? :reindex_extent
          ActiveSupport::Notifications.instrument("import.importer", arg_hash) { update }
        else
          ActiveSupport::Notifications.instrument("import.importer", arg_hash.merge(name: "CREATE")) { create }
        end

        yield(object) if block_given?

        object
      end

      # An ActiveFedora bug when there are many habtm <-> has_many associations means they won't all get saved.
      # https://github.com/projecthydra/active_fedora/issues/874
      # 2+ years later, still open!
      # rubocop:disable Metrics/MethodLength
      def create
        attrs = create_attributes
        @object = klass.new
        object.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX if object.respond_to? :reindex_extent
        run_callbacks :save do
          run_callbacks :create do
            if klass == ::AdminSet
              create_admin_set(attrs)
            elsif klass == ::Collection
              create_collection(attrs)
            else
              work_actor.create(environment(attrs))
            end
          end
        end
        log_created(object)
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/CyclomaticComplexity
      def update
        raise "Object doesn't exist" unless object

        destroy_existing_files if @replace_files && (klass != ::Collection || klass != ::AdminSet)
        attrs = update
        run_callbacks :save do
          if klass == ::AdminSet
            update_admin_set(attrs)
          elsif klass == ::Collection
            update_collection(attrs)
          else
            work_actor.update(environment(attrs))
          end
        end
        log_updated(object)
      end
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/CyclomaticComplexity

      def create_admin_set(attrs)
        attrs.delete("collection_type_gid")
        object.members = members
        object.attributes = attrs
        object.save!
      end

      def update_admin_set(attrs)
        attrs.delete("collection_type_gid")
        object.members = members
        object.attributes = attrs
        object.save!
      end

      def find
        if attributes[:id]
          find_by_id
        elsif attributes[system_identifier_field].present? && klass.new.respond_to?(system_identifier_field)
          search_by_identifier
        elsif klass == AdminSet && attributes[:title].present?
          search_by_title_or_identifier
        end
      end

      def search_by_title_or_identifier
        AdminSet.where(title: Array(attributes[:title]).first).first || AdminSet.where(id: Array(attributes[:title]).first).first
      end

      def permitted_attributes
        klass.properties.keys.map(&:to_sym) + %i[id edit_users edit_groups read_groups visibility work_members_attributes admin_set_id]
      end

      # Override if we need to map the attributes from the parser in
      # a way that is compatible with how the factory needs them.
      def transform_attributes
        if klass == ::Collection || klass == ::AdminSet
          attributes.slice(*permitted_attributes)
        else
          attrs = attributes.slice(*permitted_attributes).merge(file_attributes)
          attrs = attrs.merge("file_set" => attributes["file_set"])

          if attrs["file_set"].present?
            attrs["uploaded_files"].each_with_index do |id, i|
              attrs["file_set"][i]["uploaded_file_id"] = id if attrs["file_set"][i].present?
            end
          end

          attrs
        end
      end
    end
  end
end
