# frozen_string_literal: true

require 'csv'

def clean_zipcode(zipcode)
  # if nil return a default code
  zipcode = '00000' if zipcode.nil?

  case zipcode.size
  when 5 then nil # it's ok
  # add 0 at start until size == 5
  when 0..5 then zipcode = zipcode.rjust(5, '0')
  # if > 5, return the first 5 nums
  else zipcode = zipcode[0, 5] end

  zipcode
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
