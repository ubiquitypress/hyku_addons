# frozen_string_literal: true
require 'csv'

# Run this script as bundle exec rails r <tenant_cname> <path/to/import.csv>
tenant = ARGV[0]
csv = CSV.read(ARGV[1])
headers = csv[0]
col = headers.index('admin_set')
admin_sets = csv.slice(1..csv.length).collect { |row| row[col] }.uniq
puts "Creating in #{tenant} the following admin sets: #{admin_sets}"
AccountElevator.switch!(tenant)
admin_sets.each do |admin_set|
  if AdminSet.where(title: admin_set).any?
    puts "Skipping #{admin_set} because it already exist."
    next
  end
  AdminSet.create!(title: [admin_set])
end
