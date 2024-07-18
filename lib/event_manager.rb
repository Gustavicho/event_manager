# frozen_string_literal: true

require 'csv'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0, 5]
end

puts 'Event Manager Initialized!'

if File.exist? 'event_attendees.csv'
  contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
  )

  contents.each do |row|
    name = row[:first_name]
    zipcode = clean_zipcode row[:zipcode]

    puts "#{name.ljust(10)}-> #{zipcode}"
  end
else
  puts 'IMPOSSIBLE FIND FILE'
end
