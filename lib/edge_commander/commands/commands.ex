defmodule EdgeCommander.Commands do
  import Ecto.Query, warn: false
  import EdgeCommander.ThreeScraper, only: [all_sim_numbers: 0, get_last_two_days: 1]
  alias EdgeCommander.Repo
  require Logger

  def usage_command do
    
  end
end