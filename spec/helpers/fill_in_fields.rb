# frozen_string_literal: true;

# Fill in a single text field
def fill_in_text_field(field, value)
  fill_in_field(field, value, :input)
end

# Fill in a single textarea
def fill_in_textarea(field, value)
  fill_in_field(field, value, :textarea)
end

# Fill in a single select field
def fill_in_select(field, value)
  fill_in_field(field, value, :select)
end

# Fill in a date field from a hash, or array of hashes, containing :year, :month, :day keys
def fill_in_date_field(field, value)
  value.each do |type, value|
    field_id = "#{work_type}[#{field}][][#{field}_#{type}]"

    expect(page).to have_field(field_id)
    select(value, from: field_id)
  end
end

def fill_in_cloneable_date_field(field, value)
  values = Array.wrap(value)

  within "div.#{work_type}_#{field}[data-cloneable]" do
    values.each_with_index do |hash, index|
      groups = all("[data-cloneable-group=#{work_type}_#{field}]")
      group = groups[index]

      hash.each do |type, value|
        field_id = "#{work_type}[#{field}][][#{field}_#{type}]"

        expect(page).to have_field(field_id)
        group.select(value, from: field_id)
      end

      click_on "Add another" if index+1 < values.size && field_config.dig(field, :multiple)
    end
  end
end

# Fill in a cloneable element like Creator/Contributor
def fill_in_cloneable(field, value)
  values = Array.wrap(value)

  within "div.#{work_type}_#{field}[data-cloneable]" do
    values.each_with_index do |hash, index|
      groups = all("[data-cloneable-group=#{work_type}_#{field}]")
      group = groups[index]

      name_type = hash.delete("#{field}_name_type".to_sym) || "Personal"
      group.select(name_type, from: "#{work_type}_#{field}__#{field}_name_type")

      hash.each do |subfield, val|
        field_type = field_config.dig(:creator, :subfields, subfield, :type)

        case field_type
        when "select"
          group.find("select.#{work_type}_#{subfield}").find(:option, val).select_option
        else
          group.find("input.#{work_type}_#{subfield}").set(val)
        end
      end

      click_on "Add another" if index+1 < values.size
    end
  end
end

# FIll in a multiple select field
def fill_in_multiple_selects(field, value)
  values = Array.wrap(value)

  within "div.#{work_type}_#{field}" do
    values.each_with_index do |val, index|
      group = find("ul li:nth-of-type(#{index+1})")

      input = group.find("select.#{work_type}_#{field}")

      input.find(:option, val).select_option

      click_on "Add another" if index+1 < values.size
    end
  end
end

# Fill in a field of a specified type
def fill_in_field(field, value, type)
  field = find("div.#{work_type}_#{field} #{type}")

  if type == :select
    field.find(:option, value).select_option
  else
    field.fill_in(with: value)
  end
end

# Fill in a multiple text field
def fill_in_multiple_text_fields(field, value)
  fill_in_multiple_fields(:input, field, value)
end

def fill_in_multiple_textareas(field, value)
  fill_in_multiple_fields(:textarea, field, value)
end

def fill_in_multiple_fields(type, field, value)
  values = Array.wrap(value)

  within "div.#{work_type}_#{field}" do
    values.each_with_index do |val, index|
      find("ul li:nth-of-type(#{index+1})").find("#{type}.#{work_type}_#{field}").set(val)

      click_on "Add another" if index+1 < values.size
    end
  end
end

# Funder uses the legacy multiple json values so needs its own helper method
def fill_in_funder(value)
  values = Array.wrap(value)

  values.each_with_index do |funder, index|
    group = all("div.#{work_type}_funder")[index]

    funder.each do |subfield, val|
      group.find("input[name='ubiquity_template_work[funder][][#{subfield}]']").fill_in(with: val)
    end

    group.find_link("Add another Funder").click if index+1 < values.size
  end
end

def ss
  page.save_screenshot
end
