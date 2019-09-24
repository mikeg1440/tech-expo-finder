require 'pry-moves'
require 'nokogiri'
require 'open-uri'
require 'json'
require_relative '../lib/event.rb'
require_relative '../lib/scraper.rb'


# puts doc.css("#event-list tr").count

def main
  # url = "https://10times.com/top100/technology"
  url = File.read("pages/top100.html")
  doc = Nokogiri::HTML(url)
  # doc = scrape_page(url)

  create_events(doc)


  zipcode = get_user_zipcode


  region = get_region_from_zip(zipcode)

  country = region.split("/").first
  country = "USA" if country == "America"

  events = get_events_in_country(country)

  puts region

end

def get_events_in_country(country)
  binding.pry
end

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

def create_events(doc)

  doc.css("tbody tr").each do |element|

    next if element.text == "RankEventWhenWhereCategoryRating"

    if element.text != ""
      name = element.css(".box-link strong").text.strip
      if element.css("td strong")[1] == nil
        binding.pry
      end
      date = element.css("td strong")[1].text.strip
      country = element.css("td a.block").text.strip
      city = element.css("td small.text-muted").first.text.strip

      new_event = Event.new(name, date, country, city)

    end

  end

end

def scrape_page(url)
  html = open(url)

  doc = Nokogiri::HTML(html)
end

main
