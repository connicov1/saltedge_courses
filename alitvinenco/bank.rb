require_relative "./credit"

class Bank
  CREDIT_TIMES = [6, 12, 24, 36]
  INTEREST_RATES = 3.0..5.0

  attr_reader :name, :city, :country, :max_credit_value, :min_credit_value, :interest_rate, :credit_time
  def initialize(name, city, country, max_credit_value, min_credit_value)
    @name = name  # MAIB
    @city = city
    @country = country
    @max_credit_value = max_credit_value
    @min_credit_value = min_credit_value
    @credit_time = CREDIT_TIMES.sample
    @interest_rate = calculate_interest_rate
  end

  def calculate_interest_rate
    5 + rand(INTEREST_RATES) / @credit_time * 10
  end

  def full_name
    "#{name.downcase.include?('bank') ? name : name + 'bank'}, #{city}, #{country}"
  end

  def issue_loan(customer, credit_amount)
    raise "Подрости!" unless customer.adult?
    raise "Переедь!" unless customer.country == country
    raise "CreditDenied" unless credit_allowed?(credit_amount)
    raise "Не оплатишь!"  if calculate_monthly_debt(credit_amount) > customer.salary * 0.3
    Credit.new(
      customer,
      self,
      credit_amount,
      0,
      Date.today,
      Date.today + credit_time * 30
  )
  end

  private

  def calculate_monthly_debt(credit_amount)
    credit_amount / credit_time + credit_amount / credit_time * interest_rate
  end

  def credit_allowed?(credit_amount)
    min_credit_value < credit_amount && credit_amount < max_credit_value
  end
end
