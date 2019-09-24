
class Event

  attr_accessor :name, :location, :date, :country, :city, :state

  @@all = []

  def initialize(name, date, country, city, state)

    @name = name
    @date = date
    @country = country
    @city = city
    @state = state
    @location = {
      city: city,
      state: state,
      country: country
    }

    @@all << self
  end

  def self.all
    @@all
  end

end
