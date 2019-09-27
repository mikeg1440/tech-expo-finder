require 'nokogiri'
require 'open-uri'
require 'json'


class Location

  attr_accessor :city, :state,:country, :region, :location_info
  attr_reader :events

  @@all = []

  def initialize(city, state, country, event=nil)
    @city = city
    @state = state
    @country = country
    add_event(event) if event 
    save
  end

  def add_event()

  def self.all
    @@all
  end

  def get_info_by_zipcode(zipcode)

    url = "https://www.zipcodeapi.com/rest/ZLj7GLdIDUTjJ0OWlaMIsYkXKMgRTJ0bZ4itlMOfDbtX9jrFBcQEpe9p6GrkMnRp/info.json/#{zipcode}/degrees"

    html = open(url)

    doc = Nokogiri::HTML(html)

    JSON.parse(doc.text)
  end


  private

  def save
    @@all << self
  end

end
