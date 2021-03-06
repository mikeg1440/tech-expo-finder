
class EventScraperCli::Location

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
    @@all.detect {|location| location.city == city && location.country == country } || Location.new(city, state, country, event)
  end

  def self.all
    @@all
  end

  def self.countries
    self.all.uniq {|location| location.country }.sort_by {|location| location.country}
  end

  def self.cities
    self.all.uniq {|location| location.city}.sort_by { |l| l.city }
  end


  private

  def save
    @@all << self
  end

end
