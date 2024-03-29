# frozen_string_literal: true

# Fillin the form files
#
# @param wait [Integer] the period we should wait for
def fill_in_files(wait = 10)
  within("span#addfiles") do
    attach_file("files[]", Rails.root.join("spec", "fixtures", "hyrax", "image.jp2"), visible: false)
    attach_file("files[]", Rails.root.join("spec", "fixtures", "hyrax", "jp2_fits.xml"), visible: false)
  end

  # We need to do this anyway, so lets just keep it here rather than everyonewhere else
  within(".files") { have_selector("button.delete", count: 2, wait: wait) } if wait.positive?
end

# Fill in a single text field
#
# @param field [Symbol] the field that we wish to target
# @param value [String] the value being set
def fill_in_text_field(field, value)
  fill_in_field(field, value, :input)
end

# Fill in a single textarea
#
# @param field [Symbol] the field that we wish to target
# @param value [String] the value being set
def fill_in_textarea(field, value)
  fill_in_field(field, value, :textarea)
end

# Fill in a single select field
#
# @param field [Symbol] the field that we wish to target
# @param value [String] the value being set
def fill_in_select(field, value)
  fill_in_field(field, value, :select)
end

# Fill in a date field, delegating to either single or cloneable helper methoods is multiple set in config
#
# @param field [Symbol] the field that we wish to target
# @param values [Hash, Array] the hash (or array of hashes) where each key is the name of the subfield
#   i.e. { year: "2023", month: "03", day: "03" }
def fill_in_date(field, values)
  method = field_config.dig(field, :multiple).present? ? :fill_in_cloneable_date_field : :fill_in_singular_date_field

  send(method, field, values)
end

# Fill in a date field from a hash, or array of hashes, containing :year, :month, :day keys
#
# @param field [Symbol] the field that we wish to target
# @param values [Hash, Array] the hash (or array of hashes) where each key is the name of the subfield
#   i.e. { year: "2023", month: "03", day: "03" }
def fill_in_singular_date_field(field, values)
  values.each do |type, value|
    field_id = "#{work_type}[#{field}][][#{field}_#{type}]"

    expect(page).to have_field(field_id)
    select(value, from: field_id)
  end
end

# Complete a cloneable form date field
#
# @param field [Symbol] the field that we wish to target
# @param values [Hash, Array] the hash (or array of hashes) must contain year, month, day
#   i.e. { year: "2023", month: "03", day: "03" }
def fill_in_cloneable_date_field(field, values)
  values = Array.wrap(values)

  within "div.#{work_type}_#{field}[data-cloneable]" do
    values.each_with_index do |hash, index|
      groups = all("[data-cloneable-group=#{work_type}_#{field}]")
      group = groups[index]

      hash.each do |type, value|
        field_id = "#{work_type}[#{field}][][#{field}_#{type}]"

        expect(page).to have_field(field_id)
        group.select(value, from: field_id)
      end

      click_on "Add another" if index + 1 < values.size && field_config.dig(field, :multiple)
    end
  end
end
# rubocop:enable Metrics/MethodLength

# Fill in a cloneable element like Creator/Contributor/Editor
# @param field [Symbol] the field that we wish to target
# @param values [Hash, Array] the hash (or array of hashes) where each key is the name of the subfield
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/CyclomaticComplexity
def fill_in_cloneable(field, values)
  values = Array.wrap(values)

  within "div.#{work_type}_#{field}[data-cloneable]" do
    values.each_with_index do |hash, index|
      groups = all("[data-cloneable-group=#{work_type}_#{field}]")
      group = groups[index]

      # Incase cloneable isn't toggleable, like funder
      if (name_type = hash["#{field}_name_type".to_sym]).present?
        group.select(name_type, from: "#{work_type}_#{field}__#{field}_name_type")
      end

      hash.each do |subfield, val|
        # We can't delete the name type or it is removed from the object entirely
        next if subfield == "#{field}_name_type".to_sym

        # HACK: To get around funder awards being an array but this method not yet supporting
        # the nested cloneable subfields and clicking links which that would require.
        val = Array.wrap(val).first

        case field_config.dig(field, :subfields, subfield.to_sym, :type)
        when "select"
          group.find("select.#{work_type}_#{subfield}").find(:option, val).select_option

        when "hidden"
          # When there is a hidden field, we shouldn't be updating that as its outside of the scope of Capybara
          nil # Rubocop

        when nil
          raise "The field #{subfield}, could not be found in the Schema for #{work_type.classify}."

        else
          # Some JSON fields have a field labelled after the parent, but the parent class is used to identify
          # the fields, it will appear on both f them, so causing a "duplicate element found" error. An example of this
          # is alternate_identifier, which has fields alternate_identifier and alternate_identifer_type
          group.find_all("input.#{work_type}_#{subfield}")[0].set(val)
        end
      end

      next if index + 1 >= values.size

      # Ensure we only click the "Add another" link for the parent, not any subfields
      selector = "a[data-cloneable-target='#{work_type}_#{field}'][data-on-click='clone_group']"
      find(selector).click
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/CyclomaticComplexity

# FIll in a multiple select field
#
# @param field [Symbol] the field that we wish to target
# @param values [Array] the values to be added as an array of Strings
def fill_in_multiple_selects(field, values)
  values = Array.wrap(values)

  within "div.#{work_type}_#{field}" do
    values.each_with_index do |value, index|
      group = find("ul li:nth-of-type(#{index + 1})")

      input = group.find("select.#{work_type}_#{field}")

      input.find(:option, value).select_option

      click_on "Add another" if index + 1 < values.size
    end
  end
end

# Fill in a field of a specified type
#
# @param field [Symbol] the field that we wish to target
# @param value [String, Array] the value to be added
# @param type  [Symbol] the input type being targeted, i.e. :select
def fill_in_field(field, value, type)
  # We can allow let values to be arrays for easier comparison by doing this
  value = Array.wrap(value).first
  field = find("div.#{work_type}_#{field} #{type}")

  if type == :select
    field.find(:option, value).select_option
  else
    field.fill_in(with: value)
  end
end

# A wrapper function to fill in a multiple text fields
#
# @param field [Symbol] the field that we wish to target
# @param values [Array] the values to be added
def fill_in_multiple_text_fields(field, values)
  fill_in_multiple_fields(field, values, :input)
end

# A wrapper function to fill in a multiple text fields
#
# @param field [Symbol] the field that we wish to target
# @param values [Array] the values to be added
def fill_in_multiple_textareas(field, values)
  fill_in_multiple_fields(field, values, :textarea)
end

# A method to add set an array of values on a multiple field
#
# @param field [Symbol] the field that we wish to target
# @param values [Array] the values to be added
# @param type  [Symbol] the input type being targeted, i.e. :select
def fill_in_multiple_fields(field, values, type)
  values = Array.wrap(values)

  within "div.#{work_type}_#{field}" do
    values.each_with_index do |val, index|
      find("ul li:nth-of-type(#{index + 1})").find("#{type}.#{work_type}_#{field}").set(val)

      click_on "Add another" if index + 1 < values.size
    end
  end
end

# Fields like current_he_institution need to be updated as they are legacy from hyku1
def fill_in_legacy_json_field(field, value)
  # Allow array to be passed, using only the first element, to make comparing values easier in expectations
  value = Array.wrap(value).first

  within "div.#{work_type}_#{field}" do
    value.each do |subfield, val|
      field_type = field_config.dig(field, :subfields, subfield, :type)

      case field_type
      when "select"
        find("select.#{work_type}_#{subfield}").find(:option, val).select_option
      else
        find("input.#{work_type}_#{subfield}").set(val)
      end
    end
  end
end

# Some fields have not been updated for years, alternative_identifier/related_identifier for example
# rubocop:disable Metrics/MethodLength
def fill_in_legacy_cloneable_field(field, value)
  values = Array.wrap(value)

  within "div.#{work_type}_#{field}[data-legacy-cloneable]" do
    values.each_with_index do |hash, index|
      groups = all("[data-legacy-cloneable-group]")
      group = groups[index]

      hash.each do |subfield, val|
        field_type = field_config.dig(field, :subfields, subfield, :type)

        case field_type
        when "select"
          group.find("select.#{work_type}_#{subfield}").find(:option, val).select_option
        else
          group.find("input.#{work_type}_#{subfield}").set(val)
        end
      end

      click_on "Add another" if index + 1 < values.size
    end
  end
end
# rubocop:enable Metrics/MethodLength
