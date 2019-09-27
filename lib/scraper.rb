require 'open-uri'
require 'nokogiri'
require 'pry-moves'

class Scraper

  attr_accessor :url, :doc

  @@all = []

  def initialize(url = "pages/top100.html")

    @url = url

    if url != "pages/top100.html"
      open_from_url(url)
    else
      open_from_file(url)
    end
  end

  def open_from_file(filepath = "pages/top100.html")
    url = File.read(filepath)
    @doc = Nokogiri::HTML(url)
    save
    @doc
  end

  def open_from_url(url)
    html = open(url)
    @doc = Nokogiri::HTML(html)
    save
    @doc
  end


  private

  def save
    @@all << self
  end


end
