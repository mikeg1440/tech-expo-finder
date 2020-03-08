
class EventScraperCli::Event

  attr_accessor :name, :location, :start_date, :end_date, :date_string, :url, :hours, :days,
  :description, :users, :exhibitors, :photos, :photo_url, :price,:rating, :visitors, :expected_exhibitors,
  :category, :time_data, :country, :city, :booth, :times

  @@all = []

  # def initialize( name:, start_date:, end_date:, date_string:, city:, country:, url: )
  def initialize( info )

    info.each {|key, value| self.send("#{key}=", value) }

    save_location(city, country)

    save

  end

  def self.all
    @@all
  end

  def self.get_events_by_location(location)
    events = self.all.find_all {|event| event.location == location }
    events.sort_by {|event| event.location.city}
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

    self.times.each {|time| print "\n\t\t#{time[:date]} - #{time[:hours]}\n"}

    print "\tRating: "
    print "#{self.rating}\n".green

    print "\tCategory: "
    print "#{self.category}\n".green

    print "\n\tEvent Location: "
    print "#{self.location.city}, #{self.location.country}\n".green

    print "\tExpected Visitors: "
    print "#{self.visitors}\n".green

    print "\tExpected Exhibitors: "
    print "#{self.expected_exhibitors}\n".green

    print "\tVerified Exhibitors: "
    print "#{self.exhibitors}\n".green

    print "\tEvent URL: "
    print "#{self.url}\n\n\n".green


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
