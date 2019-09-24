
class Event

  attr_accessor :name, :location, :date, :country, :city

  @@all = []

  def initialize(name, date, country, city)

    @name = name
    @date = date
    @country = country
    @city = city
    @location = [city, country]

    @@all << self
  end

  def self.all
    @@all
  end

end
