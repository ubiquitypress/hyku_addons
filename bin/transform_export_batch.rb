#!/usr/bin/env ruby
# frozen_string_literal: true
require 'csv'
require 'optparse'
require 'json'
require 'securerandom'

JSON_FIELDS = ["creator", "contributor", "editor", "funder"].freeze
DOI_REGEX = /10\.\d{4,}(\.\d+)*\/[-._;():\/A-Za-z\d]+/

options = {}
options_parser = OptionParser.new do |opts|
  opts.banner = "Usage: transform_export_batch.rb -i INPUT -o OUTPUT [options]"

  opts.on("-i", "--input INPUT", "Input batch CSV file") do |input|
    options[:input] = input
  end

  opts.on("-o", "--output OUTPUT", "Output batch CSV file") do |output|
    options[:output] = output
  end

  opts.on("-j", "--json_fields [JSON_FIELDS]", "List of JSON fields in batch") do |json_fields|
    options[:json_fields] = json_fields.split(',')
  end

  opts.on("-f", "--[no-]files", "Include files") do |files|
    options[:include_files] = files
  end

  opts.on("-n", "--limit ROWS", "Limit number of rows") do |rows|
    options[:rows] = rows.to_i
  end

  opts.on('--[no-]new-ids', "Create new ids for all rows and collections") do |new_ids|
    options[:new_ids] = new_ids
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end
options_parser.parse!

# Ensure required options are present
unless options[:input] && options[:output]
  puts options_parser.banner
  exit
end

# Setup default values
options[:include_files] = true if options[:include_files].nil?
options[:new_ids] = false if options[:new_ids].nil?
options[:json_fields] ||= JSON_FIELDS

csv = CSV.read(options[:input])
headers = csv[0]

@fields = {}

# JSON fields are excluded from the multiple fields even though they have indexed suffixes
multiple_field_names = headers.reject { |h| h.start_with?(*options[:json_fields]) }.select { |h| h.match?(/.+_\d+$/) }.collect { |h| h.sub(/_\d+$/, '') }.uniq
new_headers = headers.reject { |h| h.start_with?(*multiple_field_names) } + multiple_field_names
new_headers -= ['file'] unless options[:include_files]

# Handle fields that have indexed headers volume_1, volume_2, etc.
multiple_field_names.each do |field|
  field_indexes = headers.map.with_index { |h, i| i if h.start_with? field }.compact
  new_index = new_headers.index(field)
  @fields[field] = { old_indexes: field_indexes, new_index: new_index }
end

# Handle all other headers
headers.reject { |h| h.start_with?(*multiple_field_names) || h == 'file' }.each do |field|
  old_index = headers.index(field)
  new_index = new_headers.index(field)
  @fields[field] = { old_indexes: [old_index], new_index: new_index }
end

# Rename fields
field_mappings = {
  'id' => 'source_identifier',
  'collection_id' => 'collection',
  'work_type' => 'model',
  'additional_information' => 'add_info',
  'alternative_title' => 'alt_title',
  'organisational_unit' => 'org_unit'
}

field_mappings.each do |old_name, new_name|
  new_headers[new_headers.index(old_name)] = new_name
  @fields[new_name] = @fields.delete(old_name)
end

def gather_values(field, row, options)
  field_values = row.values_at(*@fields[field][:old_indexes])
  if field == 'resource_type'
    model_name = row.values_at(*@fields["model"][:old_indexes]).first
    field_values.map { |v| v.delete_prefix(model_name + " ").delete_prefix('default ') }
  elsif field == 'model'
    # FIXME: make this model mapping configurable
    field_values.map { |v| "Pacific" + v.delete_suffix("Work") }
  elsif field == 'doi'
    # Extract DOI from DOI url
    field_values.map do |v|
      v&.match(DOI_REGEX)&.to_s
    end
  elsif field == 'file'
    # Placeholder file for now
    ['nypl-hydra-of-lerna.jpg']
  elsif field.match?(/_role/)
    field_values.map do |v|
      JSON.parse(v).join('|') rescue nil
    end
  elsif field == 'source_identifier'
    options[:new_ids] ? [SecureRandom.uuid] : field_values
  elsif field == 'collection'
    options[:new_ids] ? [SecureRandom.uuid] : field_values
  else
    field_values
  end
end

# transform csv by folding multiple versions of a field into single field with values separated by a pipe |
CSV.open(options[:output], "wb") do |write_csv|
  write_csv << new_headers
  csv.slice(1..options[:rows]).each do |row|
    new_row = new_headers.collect { |field| gather_values(field, row, options).select { |value| !value.nil? && value != '' }.join("|") }
    write_csv << new_row
  end
end
