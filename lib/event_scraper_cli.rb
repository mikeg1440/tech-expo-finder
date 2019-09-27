require 'colorize'


class ScraperCLI

  attr_accessor :url, :user
  attr_reader :scraper

  @@all = []

  def initialize
    @scraper = Scraper.new
    @scraper.scrape_and_create_events(@scraper.doc)
    @user = create_new_user
    save
    show_menu
  end

  def show_menu

    puts "Hello User!".green

    loop do
      puts "1. Show Events by Country".green
      puts "2. Show Events by State".green
      puts "3. Show Events by City".green
      puts "4. Show Events By Date".green
      puts "5. Get Event Info By Name".green
      puts "0. Exit".red

      print "Please Pick A Valid Menu Number: ".blue
      menu_pick = gets.chomp

      menu_pick == "0" ? break : handle_input(menu_pick)

    end

    binding.pry
  end

  def handle_input(menu_pick)
    case menu_pick
    when "1"
      get_events_by_country
    when "2"
      get_events_by_state
    when "3"
      get_events_by_city
    when "4"
      get_events_by_date
    when "5"
      get_event_by_name
    else
      puts "Invalid Menu Choice\nPlease Pick From One of The Menu Options!".red
    end
  end

  

  def create_new_user
    User.new("user_#{User.all.count+1}")
  end

  def get_user_zipcode
    print "Please Enter Your Zip-Code: ".blue
    gets.chomp
  end

  def self.all
    @@all
  end


  private

  def save
    @@all << self
  end


end
