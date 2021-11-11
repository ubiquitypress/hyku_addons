# frozen_string_literal: true

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

# Fill in a date field from a hash, or array of hashes, containing :year, :month, :day keys
#
# @param field [Symbol] the field that we wish to target
# @param values [Hash, Array] the hash (or array of hashes) where each key is the name of the subfield
#   i.e. { year: "2023", month: "03", day: "03" }
def fill_in_date_field(field, values)
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

# Fill in a cloneable element like Creator/Contributor/Editor
#
# @param field [Symbol] the field that we wish to target
# @param values [Hash, Array] the hash (or array of hashes) where each key is the name of the subfield
def fill_in_cloneable(field, values)
  values = Array.wrap(values)

  within "div.#{work_type}_#{field}[data-cloneable]" do
    values.each_with_index do |hash, index|
      groups = all("[data-cloneable-group=#{work_type}_#{field}]")
      group = groups[index]

      name_type = hash["#{field}_name_type".to_sym] || "Personal"
      group.select(name_type, from: "#{work_type}_#{field}__#{field}_name_type")

      hash.each do |subfield, val|
        # We can't delete the name type or it is removed from the object entirely
        next if subfield == "#{field}_name_type".to_sym

        case field_config.dig(field, :subfields, subfield, :type)
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

# Funder uses the legacy multiple json values so needs its own helper method
def fill_in_funder(value)
  values = Array.wrap(value)

  values.each_with_index do |funder, index|
    group = all("div.#{work_type}_funder")[index]

    funder.each do |subfield, val|
      # We are using an Array wrap here as awards are treated differently in the data
      group.find("input.ubiquity_#{subfield}").fill_in(with: Array.wrap(val).first)
    end

    group.find_link("Add another Funder").click if index + 1 < values.size
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
