# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :hyku_addons do
  namespace :file_set do
    # Usage: app:hyku_addons:file_set:regenerate_pdf_thumbnails["repo.hyku.docker"]
    desc "Regenerate thumbnails for works with grayscale thumbnails"
    task :regenerate_pdf_thumbnails, [:cname] => :environment do |_t, args|
      AccountElevator.switch!(args[:cname])

      Site.instance.available_works.each do |work_type|
        work_type = work_type.constantize

        count = work_type.count
        per_page = 25
        pages = (count.to_f / per_page.to_f).ceil

        pages.times do |page|
          work_type.limit(per_page).offset(page * per_page).each do |work|
            next if work.thumbnail.blank? || work.thumbnail.mime_type !~ /^(.)+\/pdf$/

            CreateDerivativesJob.set(wait: rand(3600)).perform_later(work.thumbnail, work.thumbnail.original_file.id)
          end

          sleep(10) # Don't kill Fedora
        end
      end
    end

    # Usage: app:hyku_addons:file_set:tenant_file_size_total["repo.hyku.docker"]
    desc "Get total file size for all files by a tenant"
    task :tenant_file_size_total, [:cname] => :environment do |_t, args|
      AccountElevator.switch!(args[:cname])
      files = FileSet.all
      sleep(0.3)

      file_size_bytes = files.map do |file|
        file&.file_size&.first&.to_f
      end.compact.sum

      file_size_megabytes = (file_size_bytes / (1024 * 1024))

      puts "#{args[:cname]} files count is #{files.size} and total file size is #{file_size_megabytes.round(2)} mb and #{file_size_bytes.round(2)} bytes"
    end
  end
end
# rubocop:enable Metrics/BlockLength
