
class Event

  attr_accessor :name, :location, :date, :country, :city, :state

  @@all = []

  def initialize(name, date, country, city, state)

    @name = name
    @date = date
    @country = country
    @city = city
    @state = state
    @location = {
      city: city,
      state: state,
      country: country
    }

    @@all << self
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

  def create_events(doc)

    doc.css("tbody tr").each do |element|

      next if element.text == "RankEventWhenWhereCategoryRating"

      if element.text != ""
        name = element.css(".box-link strong").text.strip
        date = element.css("td strong")[1].text.strip
        country = element.css("td a.block").text.strip
        city = element.css("td small.text-muted").first.text.strip
        state = get_event_state(element)

        Event.new(name, date, country, city, state)
        binding.pry
      end

    end

  end
end
