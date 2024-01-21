class HomeController < ApplicationController
  def index
    @url = params[:url]
    @scraped_data = scrape_data if @url.present?
  end

  private

  def scrape_data
    scraper_service = ScraperService.new(@url)
    scraper_service.scrape_data
  end
end
