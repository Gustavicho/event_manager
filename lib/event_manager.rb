# frozen_string_literal: true

# Required Libraries
require 'csv'
require 'erb'
require 'time'
require 'colorize'
require 'google/apis/civicinfo_v2'

# Cleans the zipcode to ensure it's a 5-digit string
def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0, 5]
end

# Cleans and formats phone numbers
def clean_phone_num(phone_num)
  cleaned = phone_num.gsub(/\D/, '')
  return cleaned[1, 10] if cleaned.length == 11 && cleaned.start_with?('1')
  cleaned
end

# Updates the hash with the most common hours
def most_common_hours!(hours_hash, date_time)
  hour = get_hour(date_time)
  hours_hash[hour] = 0 unless hours_hash.key?(hour)
  hours_hash[hour] += 1
end

# Updates the hash with the most common weekdays
def most_common_weekdays!(weekdays_hash, date_time)
  weekday = get_weekday(date_time)
  weekdays_hash[weekday] = 0 unless weekdays_hash.key?(weekday)
  weekdays_hash[weekday] += 1
end

# Extracts the weekday from the date
def get_weekday(date_time)
  date_parts = date_time.split(' ')
  date = date_parts[0].split('/')
  year = "20#{date[2]}".to_i
  month = date[0].to_i
  day = date[1].to_i
  weekday_name(Date.new(year, month, day).wday)
end

# Returns the weekday name for the given day number
def weekday_name(day)
  %w[sunday monday tuesday wednesday thursday friday saturday][day]
end

# Extracts the hour from the date and time
def get_hour(date_time)
  time_parts = date_time.split(' ')[1].split(':')
  hour = time_parts[0]
  minute = time_parts[1]
  hour = (hour.to_i + 1).to_s if minute.to_i >= 30
  hour
end

# Checks if the phone number is valid (10 digits)
def valid_phone_number?(phone_num)
  phone_num.size == 10
end

# Fetches legislators by zipcode
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

# Saves a thank you letter to a file
def save_letter(id, personal_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') { |file| file.puts personal_letter }
end

# Main script execution
puts 'EventManager initialized.'.colorize(:green)

form_letter_template = File.read('form_letter.erb')
erb_template = ERB.new(form_letter_template)

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

weekdays = {}
hours = {}

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  # code for validate phne number
  # phone_num = clean_phone_num(row[:homephone])
  # valid = valid_phone_number?(phone_num)
  # Display results of the phine numbers
  # puts "#{phone_num}: #{valid}"

  # code for update the most used wdays & hours
  # date_time = row[:regdate]
  # most_common_hours!(hours, date_time)
  # most_common_weekdays!(weekdays, date_time)

  legislators = legislator_by_zipcode(zipcode)
  personal_letter = erb_template.result(binding)
  save_letter(id, personal_letter)
end

# Display results of most used wdays & hours
# puts weekdays
# puts hours
