# frozen_string_literal: true

module Hyrax
  class BcChaptersAndBookSectionPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:bc_chapters_and_book_section)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
