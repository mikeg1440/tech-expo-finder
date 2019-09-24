require 'open-uri'
require 'nokogiri'

class Scraper

  attr_accessor

  def initialize(url)

    html = open(url)

    Nokogiri::HTML(html)

  end




end
