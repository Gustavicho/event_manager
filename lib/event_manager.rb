# frozen_string_literal: true

require 'csv'
require 'erb'
require 'time'
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

def most_commom_hrs!(hrs_hash, dta)
  h = get_hours dta
  hrs_hash[h] = 0 unless hrs_hash.key? h
  hrs_hash[h] += 1
end

def most_commom_wday!(wday_hash, dta)
  wd = get_wday dta
  wday_hash[wd] = 0 unless wday_hash.key? wd
  wday_hash[wd] += 1
end

def get_wday(dta)
  dt = dta.split(' ')
  date = dt[0].split('/')
  y = "20#{date[2]}".to_i
  m = date[0].to_i
  d = date[1].to_i
  wday_name Date.new(y, m, d).wday
end

def wday_name(day)
  case day
  when 0 then 'sunday'
  when 1 then 'monday'
  when 2 then 'tuesday'
  when 3 then 'wednesday'
  when 4 then 'thursday'
  when 5 then 'friday'
  else 'saturday' end
end

def get_hours(dt)
  dt = dt.split(' ')
  time = dt[1].split(':')
  h = time[0]
  min = time[1]
  if min.to_i >= 30
    (h.to_i + 1).to_s
  else
    h
  end
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
week_days = {}
hours = {}
contents.each do |row|
  # id = row[0]
  # name = row[:first_name]
  # zipcode = clean_zipcode row[:zipcode]
  # phone_num = clean_phone_num(row[:homephone])
  # valid = valid_num? phone_num

  date_time = row[:regdate]
  most_commom_hrs! hours, date_time
  most_commom_wday! week_days, date_time

  # legislators = legisla tor_by_zipcode zipcode
  # puts "#{phone_num}: #{is_valid}"

  # personal_letter = erb_letter.result(binding)
  # save_letter id, personal_letter
end

puts week_days
puts hours
