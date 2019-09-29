require 'nokogiri'
require 'open-uri'
require 'json'


class Location

  attr_accessor :city, :state,:country, :region, :location_info
  attr_reader :events

  @@all = []

  def initialize(city, country, event=nil)
    @city = city
    @state = state
    @country = country
    @events = []
    add_event(event) if event
    save
  end

  def add_event(event)
    @events.detect {|e| e == event} || @events << event
  end

  def find_or_create_location(city, state, country, event=nil)
    Location.all.detect {|location| location.city == city && location.country == country } || Location.new(city, state, country, event)
  end

  def self.all
    @@all
  end

  def get_info_by_zipcode(zipcode)

    url = "https://www.zipcodeapi.com/rest/ZLj7GLdIDUTjJ0OWlaMIsYkXKMgRTJ0bZ4itlMOfDbtX9jrFBcQEpe9p6GrkMnRp/info.json/#{zipcode}/degrees"

    html = open(url)

    doc = Nokogiri::HTML(html)

    JSON.parse(doc.text)
  end

  def self.countries
    countries = self.all.uniq {|location| location.country }.sort_by {|location| location.country}

    countries.sort_by {|location| location.country}
  end


  private

  def save
    @@all << self
  end

end
