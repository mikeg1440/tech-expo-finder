
class Scraper

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
    url = File.read(filepath)
    @doc = Nokogiri::HTML(url)
    save
    @doc
  end

  def open_from_url(url)
    html = open(url)
    @doc = Nokogiri::HTML(html)
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
          date: element.css("td strong")[1].text.strip,
          country: element.css("td a.block").text.strip,
          city: element.css("td small.text-muted").first.text.strip
        }

        if event_info[:date].include?(" - ")
          date_regex = event_info[:date].scan(/\S+/)

          event_info[start_date] = Date.parse(date_regex[0] << date_regex[3] << date_regex[4])
          event_info[end_date] = Date.parse(date_regex[2] << date_regex[3] << date_regex[4])
        end
        # convert date string to date object
        # date_obj = Date.parse(event_info[:date])
        # event_info[:date] = date_obj
        binding.pry


        # state = get_event_state(element)
        # state = nil
        Event.new(event_info)

      end

    end

  end

  private

  def save
    @@all << self
  end


end
