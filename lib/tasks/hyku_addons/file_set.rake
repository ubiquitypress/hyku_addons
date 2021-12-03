# frozen_string_literal: true

namespace :hyku_addons do
  namespace :file_set do
    # Usage:  dce:web:rails app:hyku_addons:file_set:regenerate_pdf_thumbnails["repo.hyku.docker"]
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
            work.file_sets.each do |file_set|
              next unless file_set.mime_type.match?(/^(.)+\/pdf$/)

              CreateDerivativesJob.set(wait: rand(3600)).perform_later(file_set, file_set.original_file.id)
            end
          end

          sleep(10) # Don't kill Fedora
        end
      end
    end
  end
end
