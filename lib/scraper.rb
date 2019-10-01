
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
    binding.pry
    @doc = Nokogiri::HTML(open(url))
    save
    @doc
  end

  def scrape_and_create_events#(doc, css_selectors = nil)

    @doc.css("tbody tr").each do |element|

      next if element.text == "RankEventWhenWhereCategoryRating"

      # css_selectors = {
      #   name: ".box-link strong",
      #   date: "td strong",
      #   country: "td a.block",
      #   city: "td small.text-muted"
      # }

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

    binding.pry

    # description_title = @doc.css(".desc strong").text.strip
    #
    # description = @doc.css(".desc").split("\n")[1].strip
    #
    # speakers = {
    #   url: @doc.css("#speakers a").first['href'],
    #   quantity: @doc.css("#speakers a").first.text.split[1]
    # }
    #
    # content = @doc.css("tr td")    

  end

  private

  def save
    @@all << self
  end


end
