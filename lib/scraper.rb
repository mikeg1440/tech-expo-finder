
class Scraper

  attr_accessor :url, :doc

  @@all = []

  # initialize with defualt of saved page file location unless given a url
  def initialize(url = "pages/top100.html")

    @url = url

    if url != "pages/top100.html"
      open_from_url(url)
    else
      open_from_file(url)
    end
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

  def scrape_and_create_events(doc)

    doc.css("tbody tr").each do |element|

      next if element.text == "RankEventWhenWhereCategoryRating"

      if element.text != ""
        location = {
          name: element.css(".box-link strong").text.strip,
          date: element.css("td strong")[1].text.strip,
          country: element.css("td a.block").text.strip,
          city: element.css("td small.text-muted").first.text.strip
        }

        # convert date string to date object
        # date_obj = Date.parse(location[:date])
        # location[:date] = date_obj


        # state = get_event_state(element)
        # state = nil
        Event.new(location)

      end

    end

  end

  private

  def save
    @@all << self
  end


end
