
class EventScraperCli::Scraper

  attr_accessor :url, :doc

  @@all = []

  # initialize with defualt of saved page file path unless given a url
  def initialize(url = "pages/top100.html")

    @url = url

    if url != "pages/top100.html"
      @doc = open_from_url(url)
    else
      @doc = open_from_file(url)
    end

    self
  end

  def open_from_file(filepath = "pages/top100.html")
    html = File.read(filepath)
    @doc = Nokogiri::HTML(html)
    save
    @doc
  end

  def open_from_url(url)
    # html = open(url)
    @doc = Nokogiri::HTML(open(url))
    save
    @doc
  end

  def scrape_and_create_events#(doc, css_selectors = nil)

    @doc.css("tbody tr").each do |element|

      next if element.text == "RankEventWhenWhereCategoryRating"

      if element.text != ""# && !css_selectors
        event_info = {
          name: element.css(".box-link strong").text.strip,
          date_string: element.css("td strong")[1].text.strip,
          country: element.css("td a.block").text.strip,
          city: element.css("td small.text-muted").first.text.strip,
          url: element.css("a").first['href']
        }

        # convert out date_string into start and end Date objects
        if event_info[:date_string].include?(" - ")
          date_regex = event_info[:date_string].scan(/\S+/)

          event_info[:start_date] = Date.parse(date_regex[0] << date_regex[3] << date_regex[4])
          event_info[:end_date] = Date.parse(date_regex[2] << date_regex[3] << date_regex[4])
        end

        EventScraperCli::Event.new(event_info)

      end

    end

  end

  def scrape_event_details(event)

    description = @doc.css(".desc strong").text

    time_data = @doc.css("#hvrout1").text.split("\n").map {|line| line.strip}
    hours = []
    days = []

    time_data.each do |line|
      hour_match = line.scan(/\d\d:\d\d [PM|AM]./)
      # day_match = line.scan(/\( ?(\w+) (\d\d)?\)/)
      day_match = line.scan(/[JFMARSND][a-z]{2} \d+/)

      hours << hour_match unless hour_match.empty?
      days << day_match unless day_match.empty?
    end


    event.hours = hours unless hours.empty?
    event.days = days unless days.empty?
    event.description = description unless description.empty?
  end

  private

  def save
    @@all << self
  end


end
