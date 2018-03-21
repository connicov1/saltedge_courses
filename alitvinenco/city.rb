class City
  attr_reader :name, :coordinates, :country
  def initialize(name, coordinates, country)
    @name = name
    @coordinates = coordinates
    @country = country
  end
end
