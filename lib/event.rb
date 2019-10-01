
class Event

  attr_accessor :name, :location, :date#, :country, :city, :state

  @@all = []

  def initialize( name:, date:, city:, country: )
    @name = name
    @date = date

    save_location(city, country)

    save

  end

  def self.all
    @@all
  end

  def self.get_events_by_location(location)
    Event.all.find_all {|event| event.location == location }
  end

  # def self.get_events_by_state(state = "USA")
  #   # events = get_events_in_country("USA")
  #
  #   # in_state = events.find_all {|event| event.state == state}
  #
  #   # in_state
  #   get_events_in_country.find_all {|event| event.state == state}.sort_by {|event| event.location.country}
  # end

  def self.get_events_by_country(country)
    self.all.find_all {|event| event.location.country == country}.sort_by {|event| event.location.country}
  end

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
  #   doc.css(".bld").text
  # end

  # prints out current instances information
  def print_event_information
    print "Event: "
    print "#{self.name}\n".green
    print "\tEvent Date: "
    print "#{self.date}\n".green
    print "\tEvent Location: "
    print "#{self.location.city}, #{self.location.country}\n\n".green
  end

  private

  # check if location already exists, if not create a new one
  def save_location(city, country)
    if !Location.all.detect {|location| location.country == country && location.city == city}
      @location = Location.new(city, country, self)
    else
      @location = Location.all.detect {|location| location.country == country && location.city == city}
    end
  end

  def save
    @@all << self
  end

end
