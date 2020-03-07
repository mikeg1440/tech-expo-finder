
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
        # name:, start_date:, end_date:, date_string:, city:, country:, url:
        EventScraperCli::Event.new(event_info)

      end

    end

  end

  def scrape_event_details(event)

    event.description = @doc.css(".desc strong").text


    event.time_data = @doc.css("#hvrout1").text.split("\n").map {|line| line.strip}
    hours = []
    days = []

    event.users = @doc.css("#visitors").text.match(/\d+/)
    event.exhibitors = @doc.css("#exhibitors").text.match(/\d+/)
    event.photos = @doc.css("#photo").text.match(/\d+/)
    event.photo_url = @doc.css("#photo").css("a")[0]['href'] unless @doc.css("#photo").css("a").empty?
    event.price = @doc.css(".text-muted.ml-10").text.strip if @doc.css(".text-muted.ml-10")
    event.rating = @doc.css(".label.label-success").text.match(/\d\.?\d\/\d/)[0] if @doc.css(".label.label-success").text.match(/\d\.?\d\/\d/)

    # if @doc.css("#hvrout2 td a").count == 3
    event.visitors = @doc.css("#hvrout2 td a")[0].text.strip
    event.expected_exhibitors = @doc.css("#hvrout2 td a")[1].text.strip
    event.category = @doc.css("#hvrout2 td a")[2].text.strip
    # end



    event.time_data.each do |line|
      hour_match = line.scan(/\d\d:\d\d [PM|AM]./)
      # day_match = line.scan(/\( ?(\w+) (\d\d)?\)/)
      day_match = line.scan(/[JFMARSND][a-z]{2} \d+/)

      hours << hour_match unless hour_match.empty?
      days << day_match unless day_match.empty?
    end


    event.hours = hours unless hours.empty?
    event.days = days unless days.empty?
  end

  private

  def save
    @@all << self
  end


end
