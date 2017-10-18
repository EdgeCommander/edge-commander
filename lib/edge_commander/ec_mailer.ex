defmodule EdgeCommander.EcMailer do

  @config Application.get_env(:edge_commander, :mailgun)
  @from "support@edgecommander.com"
  @year Calendar.DateTime.now_utc |> Calendar.Strftime.strftime!("%Y")

  def usage_monitoring(usage, number, volume_used, allowance, name) do
    Mailgun.Client.send_email @config,
      to: "junaid@evercam.io",
      subject: "Your Sim Usage has been increased much.",
      from: @from,
      # bcc: "marco@evercam.io",
      html: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "usage_monitoring.html", usage: usage, number: number, volume_used: volume_used, allowance: allowance, name: name),
      text: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "usage_monitoring.txt", usage: usage, number: number, volume_used: volume_used, allowance: allowance, name: name)
  end
end