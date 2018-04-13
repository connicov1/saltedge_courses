require 'watir'
require 'nokogiri'
require 'json'
require 'time'
require_relative './transaction'

class WebBanking
  attr_reader :browser
  def initialize
    @browser = Watir::Browser.new :chrome
  end

  def parse_accounts_data
    sign_in
    sleep(3)
    accounts = browser.divs(class: %w(contract status-active))
    accounts_info = accounts.map do |div|
      Watir::Wait.until { div.div(class: "contract-cards").a.present? }
      div.div(class: "contract-cards").a.click
      go_to_info
      page = Nokogiri::HTML.parse(browser.div(id: "contract-information").html)
      go_to_transactions
      data = {
          name: parse_name(page),
          balance: parse_balance(page),
          currency: parse_currency(page),
          description: parse_nature(page),
          transactions: transactions.map(&:to_hash)
      }
      browser.li(class: %w(new_cards_accounts-menu-item active)).a.click
      data
    end
    JSON.pretty_generate(accounts: accounts_info)
  end

  private

  def sign_in
    browser.goto 'https://wb.micb.md'
    browser.text_field(class: "username").set("*******")
    browser.text_field(id: "password").set("*******")
    browser.button(class: "wb-button").click
  end

  def go_to_info
    browser.ul(class: %w(ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all)).lis[1].click
  end

  def parse_name(page)
    page.css('tr')[6].css(".value").text
  end

  def parse_balance(page)
    page.css('tr')[8].css(".value").css('span')[0].text
  end

  def parse_currency(page)
    page.css('tr')[8].css(".value").css('span')[1].text
  end

  def parse_nature(page)
    page.css('tr')[3].css(".value").text.gsub("1. ","").gsub("2. ","")
  end

  def go_to_transactions
    browser.ul(class: %w(ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all)).lis[2].click
    Watir::Wait.until { browser.input(class: %w(filter-date from maxDateToday hasDatepicker)).present? }
    browser.input(class: %w(filter-date from maxDateToday hasDatepicker)).click
    Watir::Wait.until { browser.a(class: %w(ui-datepicker-prev ui-corner-all)).present? }
    browser.a(class: %w(ui-datepicker-prev ui-corner-all)).click
    sleep(3)
    Watir::Wait.until { browser.a(class: "ui-state-default").present? }
    browser.a(class: "ui-state-default").click   # I use the first day of the month
    sleep(3)
  end

  def transactions
    arr = browser.div(class: "operations").lis
    sleep(2)
    arr.map do |li|
      Watir::Wait.until { li.a.present? }
      li.a.click
      operation_info = Nokogiri::HTML.parse(browser.div(class: "operation-details-body").html)
      desc_operation_info = Nokogiri::HTML.parse(browser.div(class: "operation-details-header").html)
      browser.send_keys :escape
      Transaction.new(
          transaction_data(operation_info),
          transaction_description(desc_operation_info),
          transaction_amount(operation_info)
      ).to_hash
    end
  end

  def transaction_data(operation_info)
    operation_info.css('.details')[0].css('.value').text
  end

  def transaction_description(desc_operation_info)
    desc_operation_info.css('h1').text.gsub("  ","")
  end

  def transaction_amount(operation_info)
    operation_info.css('.details-section.amounts').css('.details')[0].css('.value').text
  end
end

if __FILE__ == $0
  web = WebBanking.new
  puts web.parse_accounts_data
end
