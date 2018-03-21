class Customer
  attr_reader :full_name, :city, :country, :age, :salary
  def initialize(full_name, city, country, age, salary)
    @full_name = full_name
    @city = city
    @country = country
    @age = age
    @salary = salary
 end

 def adult?
   @age > 18
 end
end
