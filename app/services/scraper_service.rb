# app/services/scraper_service.rb

require 'httparty'
require 'nokogiri'
require 'easy_translate'

class ScraperService
  def initialize(url)
    @url = url
  end

  def scrape_data
    headers = {
      'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
      'accept-encoding': 'gzip, deflate, br',
      'accept-language': 'zh-CN,zh;q=0.9,zh-TW;q=0.8,en-US;q=0.7,en;q=0.6,ja;q=0.5',
      'cache-control': 'max-age=0',
      'cookie': 'your_cookie_here',
      'sec-fetch-mode': 'navigate',
      'sec-fetch-site': 'same-origin',
      'sec-fetch-user': '?1',
      'upgrade-insecure-requests': '1',
      'user-agent': 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.96 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
    }

    response = HTTParty.get(@url, headers: headers)
    document = Nokogiri::HTML.parse(response.body)

    {
      title: translate(scrape_title(document)),
      description: translate(scrape_description(document)),
      image: scrape_image(document),
      show_price_array: scrape_show_price_array(document),
      begin_amount: scrape_begin_amount(document)
    }
  end

  private

  def scrape_title(document)
    document.at_css(".title-text").text
  end

  def scrape_description(document)
    document.at_css('meta[name="description"]')['content']
  end

  def scrape_image(document)
    img_tag = document.at_css('img.J_ImageFirstRender')
    img_tag['src']
  end

  def scrape_show_price_array(document)
    price_div = document.at_css('div.detail-price-item[data-common-price-item="Y"][data-show-begin-amount][data-show-price]')
    show_price_value = price_div['data-show-price']
    show_price_array = show_price_value.split('-').map(&:strip).map(&:to_f)

    show_price_array[0] = convert_yuan_to_uah(show_price_array.first)
    show_price_array[1] = convert_yuan_to_uah(show_price_array.last)

    show_price_array
  end

  def scrape_begin_amount(document)
    price_div = document.at_css('div.detail-price-item[data-common-price-item="Y"][data-show-begin-amount][data-show-price]')
    price_div['data-show-begin-amount']
  end

  def translate(text)
    EasyTranslate.api_key = ENV['GOOGLE_TRANSLATE_API_KEY']
    EasyTranslate.translate(text, to: :uk)
  end

  def translate_array(array)
    array.map { |text| translate(text) }
  end

  def fetch_monobank_currency_rates
    monobank_url = 'https://api.monobank.ua/bank/currency'
    response = HTTParty.get(monobank_url)
    JSON.parse(response.body)
  end

  def convert_yuan_to_uah(amount_in_yuan)
    currency_data = fetch_monobank_currency_rates

    yuan_to_uah_rate = currency_data.find { |rate| rate['currencyCodeA'].to_s == '156' && rate['currencyCodeB'].to_s == '980' }['rateCross']

    yuan_to_uah_rate
    amount_in_uah = amount_in_yuan * yuan_to_uah_rate
  end
end
