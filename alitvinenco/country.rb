class Country
  attr_reader :name, :currency
  def initialize(name, currency) # constructor
    @name = name # instance attribute
    @currency = currency # instance attribute
  end
end
