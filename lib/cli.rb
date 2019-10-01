
class EventScraperCli::CLI

  attr_accessor :url
  attr_reader :scraper

  def initialize
    @scraper = EventScraperCli::Scraper.new
    scrape_events(@scraper)
    show_menu
  end

  def show_menu
    puts "Hello User!".green

    loop do
      puts "1. Show Events by Country".green
      puts "2. Show Events by City".green
      puts "3. Show Events By Date".green
      puts "4. Get Event Info By Name".green
      # puts "5. Show Events by Region".green
      puts "!. Reload File".magenta
      puts "0. Exit".red

      print "Please Pick A Valid Menu Number: ".blue
      menu_pick = gets.chomp

      menu_pick == "0" ? break : handle_input(menu_pick)
      menu_pick = nil
    end

  end

  def handle_input(menu_pick)

    case menu_pick
    when "0"
      return
    when "1"
      find_events_by_country
    when "2"
      find_events_by_city
    when "3"
      find_events_by_date
    when "4"
      find_events_by_name
    # when "5"
    #   get_events_by_region
    when "!"
      reload_file
    else
      puts "Invalid Menu Choice\nPlease Pick From One of The Menu Options!".red
    end
  end

  def scrape_events(scraper)
    scraper.scrape_and_create_events
  end

  def get_user_reponse(question, max_option)
    response = ""
    until response.to_i.between?(1, max_option) || response == "00"
      print question.blue
      response = gets.chomp
    end
    response
  end

  # displays list of states and country then asks user to pick a state
  def find_events_by_city

    sorted_by_cities = EventScraperCli::Location.cities

    sorted_by_cities.each_with_index do |location, index|
      puts "#{index+1}. #{location.city}, #{location.country}".green
    end

    puts "00. Exit".red

    input_question = "Choose a City to View Events: "
    city_choice = get_user_reponse(input_question, sorted_by_cities.count)

    location = sorted_by_cities[city_choice.to_i - 1]

    show_events_by_location(location) unless city_choice == "00"

  end


  # displays list of countries with events, asks user to pick a country
  def find_events_by_country

    countries = EventScraperCli::Location.countries

    countries.each.with_index do |location, index|
      puts "#{index+1}. #{location.country}".green
    end

    puts "00. Exit".red

    question = "Choose a Country to View Events: "

    country_choice = get_user_reponse(question, countries.count)

    country = countries[country_choice.to_i - 1].country

    if country_choice == "00"
      return
    end

    events = EventScraperCli::Event.get_events_by_country(country)

    events.each_with_index do |event, index|
      puts "#{index+1}. #{event.name}".green
    end

    puts "00. Exit".red

    event_choice = nil

    question = "Enter a Event's Number: "

    event_choice = get_user_reponse(question, events.count)

    # events[event_choice.to_i - 1].print_event_information

    chosen_event = events[event_choice.to_i - 1]

    chosen_event.print_event_information

    get_details(chosen_event) if get_event_details?


  end

  def find_events_by_date

    user_input = ""

    until user_input.match(/\d+-\d+-\d{4}/)
      print "Please Enter a Date(MM-DD-YYYY): ".blue
      user_input = gets.chomp
    end

    month, day, year = user_input.split("-")
    user_date = Date.parse([year, month, day].join("-"))

    events = EventScraperCli::Event.all.find_all {|event| user_date.between?(event.start_date, event.end_date) }

    events.each {|event| event.print_event_information }
  end

  def find_events_by_name

    print "Enter name of Event you want to search for: ".blue
    user_input = gets.chomp

    events = EventScraperCli::Event.all.find_all {|e| e.name.downcase.match(/#{user_input.downcase}/)}

    events.each {|e| e.print_event_information}

  end

  def get_event_details?
    response = ""

    until ["y", "yes", "n", "no"].include?(response.downcase)
      print "Would you Like to See Event's Details(yes/no)".blue
      response = gets.chomp.downcase
    end

    response == "y" || response == "yes"
  end

  def get_details(event)
    # detail_scraper = EventScraperCli::Scraper.new(event.url)
    # detail_scraper.scrape_event_details
    system("xdg-open '#{event.url}'")
  end

  def show_events_by_location(location)

    events = EventScraperCli::Event.get_events_by_location(location).sort_by {|e| e.location.city}

    events.each_with_index do |event, index|
      puts "#{index+1}. #{event.name}".green
    end
    puts "00. Exit".red

    question = "Enter a Event's Number: "
    event_choice = get_user_reponse(question, events.count)

    chosen_event = events[event_choice.to_i - 1]

    chosen_event.print_event_information

    get_details(chosen_event) if get_event_details?
  end


  def reload_file
    puts "Reloading File.....".magenta

    root_dir = File.expand_path('..', __dir__)
    # Directories within the project that should be reloaded.
    reload_dirs = %w{lib bin config}
    # Loop through and reload every file in all relevant project directories.
    reload_dirs.each do |dir|
      Dir.glob("#{root_dir}/#{dir}/**/*.rb").each { |f| load(f) }
    end
    # Return true when complete.
    true
  end


end
