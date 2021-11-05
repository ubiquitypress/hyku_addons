# frozen_string_literal: true

def add_files
  click_link "Files" # switch tab
  expect(page).to have_content "Add files"
  expect(page).to have_content "Add folder"
  within("span#addfiles") do
    attach_file("files[]", Rails.root.join("spec", "fixtures", "hyrax", "image.jp2"), visible: false)
    attach_file("files[]", Rails.root.join("spec", "fixtures", "hyrax", "jp2_fits.xml"), visible: false)
  end
end

def add_visibility(visibility = :open)
  find("body").click
  choose("#{work_type}_visibility_#{visibility}")
end

def add_agreement
  check("agreement")
end

def submit
  click_on("Save")
end

# Screenshots will be saved to spec/internal_test_hyku/tmp/capybara
def ss
  page.save_screenshot
end
