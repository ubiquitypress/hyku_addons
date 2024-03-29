# frozen_string_literal: true

# Register any Hyrax related settings and add new curation concerns (works)
# rubocop:disable Metrics/BlockLength
Hyrax.config do |config|
  config.register_curation_concern :anschutz_work
  config.register_curation_concern :archival_material
  config.register_curation_concern :article
  config.register_curation_concern :book
  config.register_curation_concern :book_contribution
  config.register_curation_concern :conference_item
  config.register_curation_concern :dataset
  config.register_curation_concern :data_management_plan
  config.register_curation_concern :denver_article
  config.register_curation_concern :denver_book
  config.register_curation_concern :denver_book_chapter
  config.register_curation_concern :denver_dataset
  config.register_curation_concern :denver_image
  config.register_curation_concern :denver_map
  config.register_curation_concern :denver_multimedia
  config.register_curation_concern :denver_presentation_material
  config.register_curation_concern :denver_serial_publication
  config.register_curation_concern :denver_thesis_dissertation_capstone
  config.register_curation_concern :exhibition_item
  config.register_curation_concern :grant_record
  config.register_curation_concern :lab_notebook
  config.register_curation_concern :nsu_generic_work
  config.register_curation_concern :nsu_article
  config.register_curation_concern :open_educational_resource
  config.register_curation_concern :report
  config.register_curation_concern :research_methodology
  config.register_curation_concern :software
  config.register_curation_concern :minute
  config.register_curation_concern :time_based_media
  config.register_curation_concern :thesis_or_dissertation
  config.register_curation_concern :pacific_article
  config.register_curation_concern :pacific_book
  config.register_curation_concern :pacific_image
  config.register_curation_concern :pacific_thesis_or_dissertation
  config.register_curation_concern :pacific_book_chapter
  config.register_curation_concern :pacific_media
  config.register_curation_concern :pacific_news_clipping
  config.register_curation_concern :pacific_presentation
  config.register_curation_concern :pacific_text_work
  config.register_curation_concern :pacific_uncategorized
  config.register_curation_concern :preprint
  config.register_curation_concern :presentation
  config.register_curation_concern :redlands_article
  config.register_curation_concern :redlands_book
  config.register_curation_concern :redlands_chapters_and_book_section
  config.register_curation_concern :redlands_conferences_reports_and_paper
  config.register_curation_concern :redlands_open_educational_resource
  config.register_curation_concern :redlands_media
  config.register_curation_concern :redlands_student_work
  config.register_curation_concern :ubiquity_template_work
  config.register_curation_concern :una_archival_item
  config.register_curation_concern :una_article
  config.register_curation_concern :una_book
  config.register_curation_concern :una_chapters_and_book_section
  config.register_curation_concern :una_exhibition
  config.register_curation_concern :una_image
  config.register_curation_concern :una_open_educational_resource
  config.register_curation_concern :una_presentation
  config.register_curation_concern :una_thesis_or_dissertation
  config.register_curation_concern :una_time_based_media
  config.register_curation_concern :uva_work
  config.register_curation_concern :ung_article
  config.register_curation_concern :ung_book
  config.register_curation_concern :ung_book_chapter
  config.register_curation_concern :ung_dataset
  config.register_curation_concern :ung_image
  config.register_curation_concern :ung_thesis_dissertation
  config.register_curation_concern :ung_time_based_media
  config.register_curation_concern :ung_presentation
  config.register_curation_concern :ung_archival_material
  config.register_curation_concern :ltu_article
  config.register_curation_concern :ltu_book
  config.register_curation_concern :ltu_book_chapter
  config.register_curation_concern :ltu_dataset
  config.register_curation_concern :ltu_image
  config.register_curation_concern :ltu_presentation
  config.register_curation_concern :ltu_thesis_dissertation
  config.register_curation_concern :ltu_time_based_media
  config.register_curation_concern :ltu_serial
  config.register_curation_concern :ltu_image_artifact
  config.register_curation_concern :okc_article
  config.register_curation_concern :okc_book
  config.register_curation_concern :okc_archival_and_legal_material
  config.register_curation_concern :okc_generic_work
  config.register_curation_concern :okc_image
  config.register_curation_concern :okc_presentation
  config.register_curation_concern :okc_time_based_media
  config.register_curation_concern :okc_chapters_and_book_section
  config.register_curation_concern :bc_article
  config.register_curation_concern :bc_book
  config.register_curation_concern :bc_archival_and_legal_material
  config.register_curation_concern :bc_image
  config.register_curation_concern :bc_presentation
  config.register_curation_concern :bc_time_based_media
  config.register_curation_concern :bc_chapters_and_book_section
  config.register_curation_concern :lac_time_based_media
  config.register_curation_concern :lac_archival_material
  config.register_curation_concern :lac_image
  config.register_curation_concern :lac_thesis_dissertation
  config.register_curation_concern :lac_book
  config.register_curation_concern :esln_article
  config.register_curation_concern :esln_book
  config.register_curation_concern :esln_book_chapter
  config.register_curation_concern :esln_dataset
  config.register_curation_concern :esln_thesis_dissertation
  config.register_curation_concern :esln_presentation
  config.register_curation_concern :esln_archival_material
  config.register_curation_concern :esln_template_work

  config.license_service_class = HykuAddons::LicenseService

  # FIXME: This setting is global and affects all tenants
  config.work_requires_files = false

  config.callback.enable :task_master_after_create_fileset

  config.callback.set(:task_master_after_create_fileset) do |file_set, _user|
    HykuAddons::TaskMaster::PublishJob.perform_later(
      file_set.task_master_type,
      "upsert",
      file_set.to_task_master.to_json
    )
  end
end
# rubocop:enable Metrics/BlockLength
