
class EventScraperCli::Event

  attr_accessor :name, :location, :start_date, :end_date, :date_string, :url, :hours, :days, :description

  @@all = []

  def initialize( name:, start_date:, end_date:, date_string:, city:, country:, url: )
    @name = name
    @start_date = start_date
    @end_date = end_date
    @date_string = date_string
    @url = url

    save_location(city, country)

    save

  end

  def self.all
    @@all
  end

  def self.get_events_by_location(location)
    self.all.find_all {|event| event.location == location }
  end

  def self.get_events_by_country(country)
    self.all.find_all {|event| event.location.country == country}.sort_by {|event| event.location.country}
  end

  # prints out current instances information
  def print_event_information

    puts "\e[H\e[2J" # this clears the terminal screen

    print "Event: "
    print "#{self.name}\n".green
    print "\tEvent Date: "
    print "#{self.date_string}\n".green
    print "\tEvent Hours: "
    self.hours.each.with_index {|day, i| print "\n\t\t#{day.join(" - ")}".green} unless self.hours == nil || self.hours.empty?
    # self.hours.each.with_index {|day, i| print "\n\t\t#{self.days[i]} #{day.join(" - ")}".green} unless self.hours == nil || self.hours.empty?
    print "\n\tEvent Location: "
    print "#{self.location.city}, #{self.location.country}\n".green
    print "\tEvent URL: "
    print "#{self.url}\n\n".green
  end

  private

  # check if location already exists, if not create a new one
  def save_location(city, country)
    if !EventScraperCli::Location.all.detect {|location| location.country == country && location.city == city}
      @location = EventScraperCli::Location.new(city, country, self)
    else
      @location = EventScraperCli::Location.all.detect {|location| location.country == country && location.city == city}
    end
  end

  def save
    @@all << self
  end

end
