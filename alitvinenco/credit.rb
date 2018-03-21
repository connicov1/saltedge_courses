class Credit
  attr_reader :customer, :bank, :amount, :paid_amount, :start_date, :end_date
  def initialize(customer, bank, amount, paid_amount, start_date, end_date)
    @customer = customer
    @bank = bank
    @amount = amount
    @paid_amount = paid_amount
    @start_date = start_date
    @end_date = end_date
  end

  def pay!(money=nil)
    if money.nil?
      money = customer.salary * 0.5
    end
    @paid_amount += money
  end

  def amount_left
    @amount - @paid_amount
  end

  def monthly_debt
    bank.interest_rate.round(2)
  end
end
