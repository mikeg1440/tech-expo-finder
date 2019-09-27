require 'pry-moves'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'colorize'
require_relative '../lib/event.rb'
require_relative '../lib/scraper.rb'


# puts doc.css("#event-list tr").count

def main
  # url = "https://10times.com/top100/technology"
  # url = File.read("pages/top100.html")
  # doc = Nokogiri::HTML(url)
  # doc = scrape_page(url)

  doc = Scraper.new("")

  create_events(doc)

  zipcode = get_user_zipcode


  # region = get_region_from_zip(zipcode)

  # country = region.split("/").first
  # country = "USA" if country == "America"

  # events = get_events_in_country(country)

  user_location = get_location_info(zipcode)

  binding.pry

  events = get_events_by_state(state)

  print_events(events)

end

# def print_events(events)
#   events.each do |event|
#     print "Event: "
#     print "#{event.name}\n".green
#     print "\tEvent Date: "
#     print "#{event.date}\n".green
#     print "\tEvent Location: "
#     print "#{event.city}, #{event.country}\n\n".green
#   end
# end

# def get_events_by_state(state)
#   events = get_events_in_country("USA")
#
#   in_state = events.find_all {|event| event.state == state}
#
#   binding.pry
#
#   in_state
# end

# def get_events_by_country(country)
#   Event.all.find_all {|event| event.country == country}
# end

def get_region_from_zip(zipcode)
  info = get_location_info(zipcode)

  info["timezone"]["timezone_identifier"]
end

def get_location_info(zipcode)

  url = "https://www.zipcodeapi.com/rest/ZLj7GLdIDUTjJ0OWlaMIsYkXKMgRTJ0bZ4itlMOfDbtX9jrFBcQEpe9p6GrkMnRp/info.json/#{zipcode}/degrees"

  html = open(url)

  doc = Nokogiri::HTML(html)

  JSON.parse(doc.text)
end

def get_user_zipcode
  puts "Please Enter Your Zip-Code: "
  gets.chomp
end

# def create_events(doc)
#
#   doc.css("tbody tr").each do |element|
#
#     next if element.text == "RankEventWhenWhereCategoryRating"
#
#     if element.text != ""
#       name = element.css(".box-link strong").text.strip
#       date = element.css("td strong")[1].text.strip
#       country = element.css("td a.block").text.strip
#       city = element.css("td small.text-muted").first.text.strip
#       state = get_event_state(element)
#
#       Event.new(name, date, country, city, state)
#       binding.pry
#     end
#
#   end

# end

# def get_events_state(element)
#
#   url = element.css("td strong a").first['href']
#
#   binding.pry
#   puts "Getting Cities State From: #{url}"
#
#   html = open(url)
#
#   doc = Nokogiri::HTML(html)
#
#   # binding.pry
#
#   doc.css(".bld").text
# end

def scrape_page(url)
  html = open(url)

  doc = Nokogiri::HTML(html)
end

main
