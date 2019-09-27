require 'open-uri'
require 'nokogiri'
require 'pry-moves'

class Scraper

  attr_accessor :url, :doc

  @@all = []

  # initialize with defualt of saved page file location unless given a url
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

  def scrape_and_create_events(doc)

    doc.css("tbody tr").each do |element|

      next if element.text == "RankEventWhenWhereCategoryRating"

      if element.text != ""
        name = element.css(".box-link strong").text.strip
        date = element.css("td strong")[1].text.strip
        country = element.css("td a.block").text.strip
        city = element.css("td small.text-muted").first.text.strip
        # state = get_event_state(element)
        state = nil

        Event.new(name, date, city, country)
      end
      # binding.pry

    end

  end



  private

  def save
    @@all << self
  end


end
