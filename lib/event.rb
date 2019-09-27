
class Event

  attr_accessor :name, :location, :date, :country, :city, :state

  @@all = []

  def initialize(name, date, city, state, country)

    @name = name
    @date = date
    # @country = country
    # @city = city
    # @state = state
    # @location = {
    #   city: city,
    #   state: state,
    #   country: country
    # }

    # @location = Location.new(city, state, country)
    save_location(city, state, country)

    save

  end

  def self.all
    @@all
  end

  def print_events(events)
    events.each do |event|
      print "Event: "
      print "#{event.name}\n".green
      print "\tEvent Date: "
      print "#{event.date}\n".green
      print "\tEvent Location: "
      print "#{event.city}, #{event.country}\n\n".green
    end
  end

  def get_events_by_state(state)
    events = get_events_in_country("USA")

    in_state = events.find_all {|event| event.state == state}

    binding.pry

    in_state
  end

  def get_events_by_country(country)
    Event.all.find_all {|event| event.country == country}
  end

  def get_events_state(element)

    url = element.css("td strong a").first['href']

    binding.pry
    puts "Getting Cities State From: #{url}"

    html = open(url)

    doc = Nokogiri::HTML(html)

    # binding.pry

    doc.css(".bld").text
  end

  private

  # check if location already exists, if not create a new one
  def save_location(city, state, country)
    if !Location.all.detect {|location| location.country == country && location.city == city}
      @location = Location.new(city, state, country, self)
    else
      @location = Location.all.select {|location| location.country == country && location.city == city}
    end
  end

  def save
    @@all << self
    save_location
  end



end
