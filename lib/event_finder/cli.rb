
class EventScraperCli::CLI

  attr_accessor :url
  attr_reader :scraper, :prompt

  def call

    puts "\tHello #{Etc.getlogin}!".blue

    @scraper = EventScraperCli::Scraper.new
    # @scraper = EventScraperCli::Scraper.new('https://10times.com/top100/technology')
    @prompt = TTY::Prompt.new(help_color: :magenta, active_color: :blue)
    loop do
      break if run == 'exit'
    end
    
    exit_message
  end

  def run

    clear_screen
    print_banner
    scrape_events
    show_menu

  end

  # displays menu options to user and prompts for a selection
  def show_menu

    menu_pick = @prompt.select('Please select a menu option: ') do |menu|
      menu.choice 'Show Events by Country', 'find by country'
      menu.choice 'Show Events by City', 'find by city'
      menu.choice 'Show Events By Date', 'find by date'
      menu.choice 'Get Event Info By Name', 'find by name'
      menu.choice 'Exit', 'exit'
    end

    return menu_pick if menu_pick == 'exit'

    event = handle_input(menu_pick)

    display_info(event) if event

  end

  # handles user's menu choice and calls corresponding method
  def handle_input(menu_pick)

    case menu_pick
    when "find by country"
      event = find_events_by_country
    when "find by city"
      event = find_events_by_city
    when "find by date"
      event = find_events_by_date
    when "find by name"
      event = find_events_by_name
    end

    event
  end

  # method accepts a scraper object as argument and calls scrape_and_create_events on the object to scrape data and create event and location objects
  def scrape_events
    @scraper.scrape_and_create_events
  end

  # takes a event object argument and calls print_event_information on the object
  def display_info(event)

    event.print_event_information

    open_in_browser(event)

  end

  # [*] this method is for getting user's choice of event after events are listed with coralating numbers [*]
  # takes a question as a string and max option number then displays question and gets/validates user input
  # ** DELETE THIS AFTER CONVERTING TO TTY-PROMPTS **
  def get_user_reponse(question, max_option)
    response = ""
    until response.to_i.between?(1, max_option) || response == "00"
      print question.blue
      response = gets.chomp
    end
    response
  end

  # gets uniq sorted list of cities from Location.all objects and displays list for user to choose to view events from.
  def find_events_by_city

    locations = EventScraperCli::Location.cities

    cities_choices = locations.map do |location|
      {name: "#{location.city}, #{location.country}", value: location}
    end

    location = @prompt.select('Choose a City to View Events: ', cities_choices, per_page: 30)

    show_events_by_location(location)

  end


  def list_locations(locations, question)

    clear_screen

    binding.pry
    if question.match(/City/)
      cities_choices = locations.map {|city| {name: "#{location.city}, #{location.country}", value: city}}
      location = @prompt.select(question, cities_choices, per_page: 30)
    else
      countries_choices = locations.map {|country| {name: location.country, value: country}}
      location = @prompt.select(question, countries_choices, per_page: 30)
    end

    location
  end

  # gets unique sorted list of countries with events, then asks user to pick a country that they want to view events from
  def find_events_by_country

    countries = EventScraperCli::Location.countries

    events_hash = countries.map do |country|
      {name: country.country, value: country}
    end
    location = @prompt.select('Choose a Country to View Events: ', events_hash, per_page: 30)

    events = EventScraperCli::Event.get_events_by_country(location.country)

    events_hash = events.map do |event|
      {name: event.name, value: event}
    end

    @prompt.select("Select a Event: ", events_hash, per_page: 30)

  end


  # asks user for a date then finds all events going on during that day
  def find_events_by_date

    user_input = ""

    until user_input.match(/\d+-\d+-\d{4}/)
      print "Please Enter a Date(MM-DD-YYYY): ".blue
      user_input = gets.chomp
    end

    month, day, year = user_input.split("-")
    user_date = Date.parse([year, month, day].join("-"))

    events = EventScraperCli::Event.all.find_all do |event|
      if event.start_date && event.end_date
        return user_date.between?(event.start_date, event.end_date)
      end
    end

    if events.empty?
      clear_screen

      print "No Events Found on the date: ".red
      print "#{user_date.month}-#{user_date.day}-#{user_date.year}\n".green
      return nil
    end

    question = "Enter a Event's Number: "

    chosen_event = list_events(events, question)

    clear_screen

    get_details(chosen_event)

    chosen_event
  end



  # asks user for a search string and finds all events with any match to that string, then asks what event they want details of
  def find_events_by_name

    print "Enter name of Event you want to search for: ".blue
    user_input = gets.chomp

    events = EventScraperCli::Event.all.find_all {|e| e.name.downcase.match(/#{user_input.downcase}/)}

    question = "Select a Event: "

    chosen_event = list_events(events, question)

    chosen_event ? get_details(chosen_event) : return

    chosen_event
  end

  # this method takes a array of event objects plus a question to prompt user then lists events with numbers, gets and returns user reponse to question
  def list_events(events, question)

    clear_screen

    events_hash = events.map.with_index(1) do |event|
      {name: event.name, value: event}
    end

    @prompt.select(question, events_hash, per_page: 20)

  end


  def get_details(event)
    detail_scraper = EventScraperCli::Scraper.new(event.url)
    detail_scraper.scrape_event_details(event)
  end

  def open_in_browser(event)

    if @prompt.yes?('Open events page in Browser?')
      system("xdg-open '#{event.url}'")
    end

    clear_screen
  end

  def show_events_by_location(location)

    events = EventScraperCli::Event.get_events_by_location(location)

    events_choices = events.map do |event|
      {name: event.name, value: event}
    end

    event = @prompt.select('Select a Event: ', events_choices, per_page: 30)

    get_details(event)
    event
  end

  def exit_message
    puts "Goodbye User".blue
    puts "Exiting Now...".red
  end

  def clear_screen
    puts "\e[H\e[2J" # this clears the terminal screen
  end

  # for dev purposes
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

  def print_banner

    puts '''
___________
\_   _____/__  _________   ____
 |    __)_\  \/  /\____ \ /  _ \
 |        \>    < |  |_> >  <_> )
/_______  /__/\_ \|   __/ \____/
        \/      \/|__|
                       ___________.__            .___
                       \_   _____/|__| ____    __| _/___________
                        |    __)  |  |/    \  / __ |/ __ \_  __ \
                        |     \   |  |   |  \/ /_/ \  ___/|  | \/
                        \___  /   |__|___|  /\____ |\___  >__|
                            \/            \/      \/    \/
                            '''.magenta
  end


end
