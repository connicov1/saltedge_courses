#!/usr/bin/env ruby
require 'yaml'
require_relative "./bank"
require_relative "./city"
require_relative "./country"
require_relative "./customer"

data = YAML.load(File.read("data.yml"))

banks = data.values.map { |data| data["banks"] }.flatten
chosen_bank = banks.sample
country_data = data.values.detect do |data|
 data["banks"].include? chosen_bank
end

country = Country.new(country_data["name"], country_data["currency"])
chosen_city = country_data["cities"][country_data["cities"].keys.sample]
city = City.new(
  chosen_city["name"],
  chosen_city["coordinates"],
  country
)
bank = Bank.new(
  chosen_bank,
  city,
  country,
  100000,
  100
)

customer = Customer.new(
  "Max Payne",
  city,
  country,
  19,
  50000
)


credit = bank.issue_loan(customer, 30000)
p credit

credit.pay!(5000)

p credit.amount_left
p credit.monthly_debt
