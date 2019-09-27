
class ScraperCLI

  attr_accessor :name, :url
  attr_reader :scraper

  @@all = []

  def initialize(name)
    @name = name
    @scraper = Scraper.new 
    save
  end


  private

  def save
    @@all << self
  end


end
