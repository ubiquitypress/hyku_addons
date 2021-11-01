# frozen_string_literal: true;

def fill_in_title(value)
  fill_in("Title", with: value)
end

def fill_in_alt_title(value)
  _fill_in_multiple_text_fields(:alt_title, value)
end

def fill_in_resource_type(value)
  select(value, from: "Resource type")
end

def fill_in_creator(hash)
  name_type = hash.delete(:creator_name_type) || "Personal"
  select(name_type, from: "#{work_type}_creator__creator_name_type")

  hash.each { |field, value| find_field("#{work_type}[creator][][#{field}]").set(value) }
end

def fill_in_contributor(value)
  _fill_in_cloneable(:contributor, value)
end

def fill_in_date_published(hash)
  _fill_in_date_field(:date_published, hash)
end

def fill_in_date_accepted(hash)
  _fill_in_date_field(:date_accepted, hash)
end

def fill_in_date_submitted(hash)
  _fill_in_date_field(:date_submitted, hash)
end

def fill_in_source(value)
  _fill_in_multiple_text_fields(:source, value)
end

def _fill_in_cloneable(field, value)
  values = Array.wrap(value)

  within "div.#{work_type}_#{field}[data-cloneable]" do
    values.each_with_index do |hash, index|
      group = find("[data-cloneable-group=#{work_type}_#{field}]:nth-of-type(#{index+1})")

      name_type = hash.delete("#{field}_name_type".to_sym) || "Personal"
      group.select(name_type, from: "#{work_type}_#{field}__#{field}_name_type")

      hash.each do |subfield, val|
        group.find("input.#{work_type}_#{subfield}").set(val)
      end

      click_on "Add another" if index+1 < values.size
      ss
    end
  end
end

# Helper to dry up entering arrays of value for multiple text fields
def _fill_in_multiple_text_fields(field, value)
  values = Array.wrap(value)

  within "div.#{work_type}_#{field}" do
    values.each_with_index do |val, index|
      find("ul li:nth-of-type(#{index+1})").find("input.#{work_type}_#{field}").set(val)

      click_on "Add another" if index+1 < values.size
    end
  end
end

# Helper method so we can keep the singular dates the same
def _fill_in_date_field(field, hash)
  hash.each do |type, value|
    field_id = "#{work_type}[#{field}][][#{field}_#{type}]"

    expect(page).to have_field(field_id)
    select(value, from: field_id)
  end
end

def ss
  page.save_screenshot
end
