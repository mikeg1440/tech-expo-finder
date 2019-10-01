require 'colorize'


class ScraperCLI

  attr_accessor :url, :user
  attr_reader :scraper

  @@all = []

  def initialize
    @scraper = Scraper.new
    # @scraper.scrape_and_create_events(@scraper.doc)
    scrape_events(@scraper)
    @user = create_new_user
    save
    show_menu
  end

  def show_menu

    puts "Hello User!".green

    loop do
      puts "1. Show Events by Country".green
      puts "2. Show Events by City".green
      puts "3. Show Events By Date".green
      puts "4. Get Event Info By Name".green
      puts "5. Show Events by Region".green
      puts "0. Exit".red

      print "Please Pick A Valid Menu Number: ".blue
      menu_pick = gets.chomp

      menu_pick == "0" ? break : handle_input(menu_pick)
      menu_pick = nil
    end

  end

  def handle_input(menu_pick)

    case menu_pick
    when "1"
      find_events_by_country
    when "2"
      find_events_by_city
    when "3"
      get_events_by_date
    when "4"
      get_event_by_name
    when "5"
      get_events_by_region
    else
      puts "Invalid Menu Choice\nPlease Pick From One of The Menu Options!".red
    end
  end

  def scrape_events(scraper)


    scraper.scrape_and_create_events
  end

  # displays list of states and country then asks user to pick a state
  def find_events_by_city

    # sorted_by_cities = Location.all.uniq {|location| location.city}.sort_by { |l| l.city }

    sorted_by_cities = Location.cities

    sorted_by_cities.each_with_index do |location, index|
      puts "#{index+1}. #{location.city}, #{location.country}".green
    end

    puts "00. Exit".red

    city_choice = nil

    loop do
      print "Choose a City to View Events: ".blue
      city_choice = gets.chomp

      break if city_choice.to_i.between?(1, sorted_by_cities.count) || city_choice == "00"
    end

    # city = sorted_by_cities[city_choice.to_i - 1].city
    # country = sorted_by_cities[city_choice.to_i - 1].country
    # get_events_by_location(city, country) unless country_choice == "00"

    location = sorted_by_cities[city_choice.to_i - 1]

    show_events_by_location(location) unless city_choice == "00"

  end


  # displays list of countries with events, asks user to pick a country
  def find_events_by_country

    country_choice = nil

    countries = Location.countries
    countries.each.with_index do |location, index|
      puts "#{index+1}. #{location.country}".green

    end

    puts "00. Exit".red

    loop do

      print "Choose a Country to View Events: ".blue
      country_choice = gets.chomp

      break if country_choice.to_i.between?(1, countries.count) || country_choice == "00"
    end

    country = countries[country_choice.to_i - 1].country

    if country_choice == "00"
      return
    end

    events = Event.get_events_by_country(country)

    events.each_with_index do |event, index|
      puts "#{index+1}. #{event.name}".green
    end

    event_choice = nil

    loop do

      puts "00. Exit".red
      print "Enter a Event's Number: ".blue
      event_choice = gets.chomp

      break if event_choice.to_i.between?(1, events.count) || event_choice == "00"
    end

    events[event_choice.to_i - 1].print_event_information

  end

  # gets all events that match the given country, country defaults to USA if none given
  def get_events_by_country(country = "USA")

    event_choice = nil

    events = Event.all.find_all {|event| event.location.country == country}
    events = events.sort_by {|event| event.name}

    events.each_with_index do |event, index|
      puts "#{index+1}. #{event.name}".green
    end

    loop do

      puts "00. Exit".red
      print "Enter a Event's Number: ".blue
      event_choice = gets.chomp

      break if event_choice.to_i.between?(1, events.count) || event_choice == "00"
    end

    events[event_choice.to_i - 1].print_event_information

  end


  def show_events_by_location(location)

    events = Event.get_events_by_location(location).sort_by {|e| e.location.city}

    events.each_with_index do |event, index|
      puts "#{index+1}. #{event.name}".green
    end

    event_choice = nil

    loop do

      puts "00. Exit".red
      print "Enter a Event's Number: ".blue
      event_choice = gets.chomp

      break if event_choice.to_i.between?(1, events.count) || event_choice == "00"
    end

    events[event_choice.to_i - 1].print_event_information


  end

  def create_new_user
    User.new("user_#{User.all.count+1}")
  end

  # def get_user_zipcode
  #   print "Please Enter Your Zip-Code: ".blue
  #   gets.chomp
  # end

  def self.all
    @@all
  end


  private

  def save
    @@all << self
  end


end
