defmodule ThreeScraper.Cookie do
  use GenServer
  require Logger

  @url "https://login.three.ie"
  @timeout 60_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get do
    GenServer.call(__MODULE__, :get, @timeout)
  end

  def update do
    GenServer.call(__MODULE__, :update, @timeout)
  end

  def set(cookie) do
    GenServer.call(__MODULE__, {:set, cookie})
  end


  def init(_args) do
    {:ok, get_cookies(0)}
  end

  def handle_call(:get, _from, cookies) do
    {:reply, cookies, cookies}
  end

  def handle_call(:update, _from, _old_cookies) do
    cookies = get_cookies(0)
    {:reply, cookies, cookies}
  end

  def handle_call({:set, cookie}, _from, _old_cookie) do
    {:reply, :ok, cookie}
  end

  def get_cookies(counter) do
    headers = get_headers_retry()
    cookies = :hackney.cookies(headers)
    case :proplists.get_value("ObSSOCookie", cookies) do
      [cookie | _cookie_opts] -> cookie
      :undefined ->
        Logger.error("can't get cookie")
        counter = counter + 1
         if counter == 10 do
          Logger.info("email has been sent")
          # EdgeCommander.EcMailer.three_web_failure()
         end
        get_cookies(counter)
    end
  end

  def login_form do
    username = System.get_env("THREE_USERNAME")
    password = System.get_env("THREE_PASSWORD")
    [{"username", username}, {"password", password}, {"section", "section"}]
  end

  def get_headers_retry do
    case HTTPoison.post(@url, {:form, login_form()}, [], hackney: [recv_timeout: 30_000]) do
      {:ok, %HTTPoison.Response{headers: headers}} ->
        headers
      error ->
        Logger.error(["[cookie]", ?\n, inspect(error)])
        get_headers_retry()
    end
  end
end
