

class User

  attr_accessor :name, :location

  @@all = []

  def initialize(name)
    @name = name
    save
  end

  def self.all
    @@all
  end 

  private

  def save
    @@all << self
  end

end
