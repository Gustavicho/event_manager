# frozen_string_literal: true

require 'csv'
require 'colorize'
require 'google/apis/civicinfo_v2'

def legislator_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = File.read('.gitignore/secret.key').strip

  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    )
    legislators = legislators.officials
    legislators_names = legislators.map(&:name)
    legislators_names.join(', ')
  rescue StandardError => e
    puts ("Error: #{e}\nYou can find your representatives by visiting\n"+
      'www.commoncause.org/take-action/find-elected-officials').colorize :red
    'Unknow'.colorize :yellow
  end
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0, 5]
end

puts 'EventManager initialized.'.colorize :green

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode row[:zipcode]
  legislators = legislator_by_zipcode zipcode

  puts "#{name.ljust(9)} -> #{zipcode}: #{legislators}"
end
