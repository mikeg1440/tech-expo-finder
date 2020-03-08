
class EventScraperCli::CLI

  attr_accessor :url
  attr_reader :scraper, :prompt

  def call

    puts "\tHello #{Etc.getlogin}!".blue

    @scraper = EventScraperCli::Scraper.new
    # @scraper = EventScraperCli::Scraper.new('https://10times.com/top100/technology')
    @prompt = TTY::Prompt.new(help_color: :magenta, active_color: :blue)
    run
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

    menu_pick = @prompt.select('Please Pick a Option 1-4 or type in command on the right within brackets') do |menu|
      menu.choice 'Show Events by Country', 'find by country'
      menu.choice 'Show Events by City', 'find by city'
      menu.choice 'Show Events By Date', 'find by date'
      menu.choice 'Get Event Info By Name', 'find by name'
      menu.choice 'Exit', 'exit'
    end

    event = handle_input(menu_pick)

    display_info(event) if event

  end

  # handles user's menu choice and calls corresponding method
  def handle_input(menu_pick)

    case menu_pick
    when "exit"
      return
    when "find by country"
      event = find_events_by_country
    when "find by city"
      event = find_events_by_city
    when "find by date"
      event = find_events_by_date
    when "find by name"
      event = find_events_by_name
    when "reload"
      reload_file
    # else
    #   clear_screen
    #   puts "Invalid Menu Choice\nPlease Pick From One of The Menu Options!".red
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

    sorted_cities = EventScraperCli::Location.cities

    input_question = "Choose a City to View Events: "

    location = list_locations(sorted_cities, input_question)

    show_events_by_location(location) if location

  end


  def list_locations(locations, question)

    clear_screen

    if question.match(/City/)
      locations.each_with_index do |location, index|
        puts "#{index+1}. #{location.city}, #{location.country}".green
      end
    else
      locations.each.with_index do |location, index|
        puts "#{index+1}. #{location.country}".green
      end
    end

    puts "00. Exit".red

    user_choice = get_user_reponse(question, locations.count)

    clear_screen

    return nil if user_choice == "00"

    locations[user_choice.to_i - 1]
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

    @prompt.select("Select a Event: ", events_hash)

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

    events = EventScraperCli::Event.all.find_all {|event| user_date.between?(event.start_date, event.end_date) }

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

    question = "Enter a Event's Number: "

    chosen_event = list_events(events, question)

    chosen_event ? get_details(chosen_event) : return

    chosen_event
  end

  # this method takes a array of event objects plus a question to prompt user then lists events with numbers, gets and returns user reponse to question
  def list_events(events, question)

    clear_screen

    events.each_with_index do |event, index|
      puts "#{index+1}. #{event.name}".green
    end

    puts "00. Exit".red
    # event_choice = nil

    event_choice = get_user_reponse(question, events.count)

    event_choice == "00" ? nil : events[event_choice.to_i - 1]

    events_hash = events.map.with_index(1) do |event, idx|
      {name: "#{idx+1}. #{event.name}", value: idx}
    end

    @prompt.select(question, events_hash)

  end

  def get_event_details?
    response = ""

    until ["y", "yes", "n", "no"].include?(response.downcase)
      print "Would you Like to See Event's Details(yes/no): ".blue
      response = gets.chomp.downcase
    end

    response == "y" || response == "yes"
  end

  def get_details(event)
    detail_scraper = EventScraperCli::Scraper.new(event.url)
    detail_scraper.scrape_event_details(event)
  end

  def open_in_browser(event)
    print "Open Webpage in Browser?(yes/no): ".blue
    response = gets.chomp.downcase

    clear_screen

    system("xdg-open '#{event.url}'") if response == "y" || response == "yes"
  end

  def show_events_by_location(location)

    events = EventScraperCli::Event.get_events_by_location(location).sort_by {|e| e.location.city}

    question = "Enter a Event's Number: "

    chosen_event = list_events(events, question)

    get_details(chosen_event)

    chosen_event
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
