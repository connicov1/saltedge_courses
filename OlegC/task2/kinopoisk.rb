require "watir"

class Kinopoisk

  attr_reader :browser
  def initialize
    @browser = Watir::Browser.new :chrome
    browser.goto("kinopoisk.ru")
    sleep(1)
  end

  def collect_film_data(film)
    search_film(film)
    return {} unless film_found?
    {
        name: parse_name,
        year: parse_year,
        producer: parse_producer,
        janre: parse_janre,
        main_actors: parse_main_actors,
        poster_img: parse_poster_img
    }
  end

  def search_film(cinema)
    browser.text_field(name: "kp_query").set(cinema)
    browser.input(class: "header-search-partial-component__button").click
    browser.div(class: "info").links[0].click if film_found?
  end

  def parse_name
    browser.h1(class: "moviename-big").text
  end

  def parse_year
    browser.table(class: "info")[0][1].text.to_i
  end

  def parse_producer
    browser.table(class: "info")[5].text.split[1..-2]
  end

  def parse_janre
    janre = browser.span(itemprop: "genre")
    janre.text.split("")
  end

  def parse_main_actors
    browser.div(id: "actorList").ul.text.split("\n")[0..-2].join(", ")
  end

  def parse_poster_img
    browser.div(id: "wrap").images.map(&:src).join
  end

  def film_found?
    !browser.text.match /К сожалению, по вашему запросу ничего не найдено.../
  end

end

films = ["Пираты карибского моря 3", "Гарри Поттер дары смерти 1", "pizdahui",  "звездные войны империя наносит ответный удар", "huipizda"]
kino = Kinopoisk.new
wifi_failures_count = 0
result = films.collect {|film|
  begin
  kino.collect_film_data(film)
  rescue Watir::Exception => error
    puts error
    {}
  rescue Net::ReadTimeout => error
    wifi_failures_count += 1
    sleep(1)
    retry if wifi_failures_count < 4
    {}
  end
}
puts result