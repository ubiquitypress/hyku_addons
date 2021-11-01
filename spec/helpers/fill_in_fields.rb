# frozen_string_literal: true;

def fill_in_title(value)
  fill_in("Title", with: value)
end

def fill_in_alt_title(value)
  fill_in_multiple_text_fields(:alt_title, value)
end

def fill_in_date_field(field, hash)
  hash.each do |type, value|
    field_id = "#{work_type}[#{field}][][#{field}_#{type}]"

    expect(page).to have_field(field_id)
    select(value, from: field_id)
  end
end

def fill_in_cloneable(field, value)
  values = Array.wrap(value)

  within "div.#{work_type}_#{field}[data-cloneable]" do
    values.each_with_index do |hash, index|
      groups = all("[data-cloneable-group=#{work_type}_#{field}]")
      group = groups[index]

      name_type = hash.delete("#{field}_name_type".to_sym) || "Personal"
      group.select(name_type, from: "#{work_type}_#{field}__#{field}_name_type")

      hash.each do |subfield, val|
        group.find("input.#{work_type}_#{subfield}").set(val)
      end

      click_on "Add another" if index+1 < values.size
    end
  end
end

def fill_in_select(field, value)
  find("div.#{work_type}_#{field} select").find(:option, value).select_option
end

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

# Helper to dry up entering arrays of value for multiple text fields
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

def ss
  page.save_screenshot
end
