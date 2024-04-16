# frozen_string_literal: true

# Monkey-patch override to make use of file set parameters relating to permissions
# See https://github.com/samvera/hyrax/pull/4992
module HykuAddons
  module WorkFileSetPersmissionsBehavior
    # @param [ActiveFedora::Base] work - the work object
    # @param [Array<Hyrax::UploadedFile>] uploaded_files - an array of files to attach
    # rubocop:disable Metrics/MethodLength
    def perform(work, uploaded_files, **work_attributes)
      puts "[DEBUG - PERM] Entering method"
      validate_files!(uploaded_files)
      depositor = proxy_or_depositor(work)
      user = User.find_by_user_key(depositor)
      work_permissions = work.permissions.map(&:to_hash)

      puts "[DEBUG - PERM] Get Permissions: #{work_permissions}"
      uploaded_files.each do |uploaded_file|
        next if uploaded_file.file_set_uri.present?

        actor = Hyrax::Actors::FileSetActor.new(FileSet.create, user)
        file_set_attributes = file_set_attrs(work_attributes, uploaded_file)

        puts "[DEBUG - PERM] Work Attributes #{work_attributes}"
        puts "[DEBUG - PERM] File Set Attributes #{file_set_attributes}"

        metadata = visibility_attributes(work_attributes, file_set_attributes)

        puts "[DEBUG - PERM] Got metadata #{metadata}"
        uploaded_file.update(file_set_uri: actor.file_set.uri)

        puts "[DEBUG - PERM] Setting Permissions #{work_permissions}"
        actor.file_set.permissions_attributes = work_permissions
        # NOTE: The next line is not included in the upstream PR
        # This line allows the setting of a file's title from a bulkrax import
        actor.file_set.title = Array(file_set_attributes[:title].presence)
        actor.create_metadata(metadata)
        actor.create_content(uploaded_file)
        puts "[DEBUG - PERM] Attaching to work"
        actor.attach_to_work(work, metadata)
      end

      puts "[DEBUG - PERM] DONE"
    end
    # rubocop:enable Metrics/MethodLength

    private

    # The attributes used for visibility - sent as initial params to created FileSets.
    def visibility_attributes(attributes, file_set_attributes)
      attributes.merge(Hash(file_set_attributes).symbolize_keys).slice(*permitted_attributes)
    end

    def file_set_attrs(attributes, uploaded_file)
      attrs = Array(attributes[:file_set]).find do |fs|
        fs[:uploaded_file_id].present? && (fs[:uploaded_file_id].to_i == uploaded_file&.id)
      end

      Hash(attrs).symbolize_keys
    end

    def permitted_attributes
      [
        :visibility, :visibility_during_lease, :visibility_after_lease, :lease_expiration_date, :embargo_release_date,
        :visibility_during_embargo, :visibility_after_embargo
      ]
    end
  end
end
