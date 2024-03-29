# frozen_string_literal: true

# Helper method to add files to the work
#
# @return [void]
def add_files
  click_link "Files" # switch tab
  expect(page).to have_content "Add files"
  expect(page).to have_content "Add folder"
  within("span#addfiles") do
    attach_file("files[]", Rails.root.join("spec", "fixtures", "hyrax", "image.jp2"), visible: false)
    attach_file("files[]", Rails.root.join("spec", "fixtures", "hyrax", "jp2_fits.xml"), visible: false)
  end
end

# Helper method to set the work form visibility
#
# @param visibility [Symbol] the work visibility, :open, :restricted, :lease, :authenticated, :embargo
# @return [void]
# Click the body, then the last li on the page, which will be the last in the visibility options, to help Capybara find it
def add_visibility(visibility = :open)
  find("body").click
  find_all("li").last.click
  choose("#{work_type}_visibility_#{visibility}")
end

# Helper method to check the agreement checkbox
#
# @return [void]
def add_agreement
  within(".panel-footer") do
    have_selector("#agreement", wait: 5)
    find("#agreement").check
    ss
  end
end

# Helper method to submit the form
#
# @return [void]
def submit
  within(".panel-footer") do
    have_selector("[name=save_with_files]", wait: 5)
    find("[name=save_with_files]").click
    ss
  end
end

# Get the actual work from the URL param
def work_uuid_from_url
  current_uri = URI.parse(page.current_url)
  current_uri.path.split("/").last
end

# Helper method to save a screenshot. Screenshots will be saved to spec/internal_test_hyku/tmp/capybara
#
# @return [void]
def ss
  page.save_screenshot
end

# Scroll the page by a given amount
#
# @param by [Integer] the amount to scroll by
# @return [void]
def scroll(by = 1000)
  page.execute_script "window.scrollBy(0,#{by})"
end

# Concert from zero prefixed to non-zero prefixed
#
# @param value [Array, Hash] the Hash or Array of hashes to be conerted
# @return [Array]
def normalize_date(value)
  dates = Array.wrap(value)

  dates.map do |date|
    date = Date.new(*date.values.map(&:to_i))
    [date.year, date.month, date.day].join("-")
  end
end
