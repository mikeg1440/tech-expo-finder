
class EventScraperCli::Scraper

  attr_accessor :url, :doc

  @@all = []

  # initialize with defualt of saved page file path unless given a url
  # default url should be https://10times.com/top100/technology
  def initialize(url = "pages/top100.html")
    @url = url
    @doc = open_from_url(url)
    self
  end

  def open_from_url(url)
    Nokogiri::HTML(open(url))
  end

  def scrape_and_create_events#(doc, css_selectors = nil)

    @doc.css("tbody tr").each do |element|

      next if element.text == "RankEventWhenWhereCategoryRating"

      if element.text != ""
        event_info = {
          name: element.css("strong").first.text.strip,
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

        EventScraperCli::Event.new(event_info) unless EventScraperCli::Event.all.find {|event| event.url == event_info[:url]}

      end

    end

  end

  def scrape_event_details(event)

    event.description = @doc.css(".desc strong").text


    time_data = @doc.css("#hvrout1").first.text.scan(/(\d{1,2}:\d{2} [AM|PM]{2} \- \d{1,2}:\d{2} [PM|AM]{2})\s+(\(\w+ \d{2}\))/)
    booth_data = @doc.css("#hvrout1").first.text.match(/(Exhibit Booth Cost) ([\w ]+)View Details$/)

    event.booth = {cost: booth_data[1]} if booth_data
    event.times = time_data.map {|date_time| {date: date_time[1], hours: date_time[0]}}

    event.users = @doc.css("#visitors").text.match(/\d+/)[0] if @doc.css("#visitors").text.match(/\d+/)
    event.exhibitors = @doc.css("#exhibitors").text.match(/\d+/)[0] if @doc.css("#exhibitors").text.match(/\d+/)
    event.visitors = @doc.css('.table.noBorder.mng').text.match(/\d+ Visitors/)[0] if @doc.css('.table.noBorder.mng').text.match(/\d+ Visitors/)
    event.photos = @doc.css("#photo").text.match(/\d+/)[0] if @doc.css("#photo").text.match(/\d+/)
    event.photo_url = @doc.css("#photo").css("a")[0]['href'] unless @doc.css("#photo").css("a").empty?
    event.price = @doc.css(".text-muted.ml-10").text.strip if @doc.css(".text-muted.ml-10")
    event.rating = @doc.css(".label.label-success").text.match(/\d\.?\d\/\d/)[0] if @doc.css(".label.label-success").text.match(/\d\.?\d\/\d/)

    if @doc.css("#hvrout2 td a").count == 3
      event.expected_exhibitors = @doc.css("#hvrout2 td a")[1].text.strip
      event.category = @doc.css('#hvrout2 a').text
    end

  end

  private

  def save
    @@all << self
  end


end
