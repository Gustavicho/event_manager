# frozen_string_literal: true

require 'csv'
require 'erb'
require 'colorize'
require 'google/apis/civicinfo_v2'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0, 5]
end

def clean_phone_num(phone_num)
  cleaned = phone_num.gsub(/\D/, '')
  return cleaned[1, 10] if cleaned.length == 11 && cleaned.start_with?('1')

  cleaned
end

def valid_num?(phone_num)
  return true if phone_num.size == 10
  
  false
end

def legislator_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = File.read('secret.key').strip

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_letter(id, personal_letter)
  Dir.mkdir 'output' unless Dir.exist? 'output'

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts personal_letter
  end
end

puts 'EventManager initialized.'.colorize :green

form_letter = File.read 'form_letter.erb'
erb_letter = ERB.new form_letter

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  # id = row[0]
  # name = row[:first_name]
  # zipcode = clean_zipcode row[:zipcode]

  phone_num = clean_phone_num(row[:homephone])
  is_valid = valid_num? phone_num

  puts "#{phone_num}: #{is_valid}"
  # legislators = legisla tor_by_zipcode zipcode

  # personal_letter = erb_letter.result(binding)
  # save_letter id, personal_letter
end
