defmodule ThreeScraper.API do
  use HTTPoison.Base
  alias ThreeScraper.Cookie

  @base_url "https://www.three.ie"

  # def process_url(:data_usage) do
  #   [@base_url, "/NASApp/MyAccount/PostpaidManageDataUsageServlet.htm"]
  # end
  def process_url(path) do
    [@base_url, path]
  end

  def process_request_options(_options) do
    [hackney: [cookie: Cookie.get(), recv_timeout: 30_000]]
  end
end
