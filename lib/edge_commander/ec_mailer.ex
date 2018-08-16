defmodule EdgeCommander.EcMailer do

  @config Application.get_env(:edge_commander, :mailgun)
  @from "support@edgecommander.com"
  @year Calendar.DateTime.now_utc |> Calendar.Strftime.strftime!("%Y")

  def usage_monitoring(senders, usage, number, volume_used, allowance, name, addon) do
    Mailgun.Client.send_email @config,
      to: Enum.join(senders, ","),
      subject: "Data usage alert (#{usage}% of #{String.trim(addon, " Broadband")}) on SIM #{number} (#{name})",
      from: @from,
      bcc: "junaid@evercam.io,ali@evercam.io",
      html: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "usage_monitoring.html", usage: usage, number: number, volume_used: volume_used, allowance: allowance, name: name, addon: addon),
      text: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "usage_monitoring.txt", usage: usage, number: number, volume_used: volume_used, allowance: allowance, name: name, addon: addon)
  end

  def send_email_for_raid(res, server) do
    IO.inspect res
    IO.inspect server
    Mailgun.Client.send_email @config,
      to: "junaid@evercam.io",
      subject: "RAID status for your server: #{server.ip}",
      from: @from,
      # bcc: "marco@evercam.io",
      html: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "send_email_for_raid.html", res: res),
      text: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "send_email_for_raid.txt", res: res)
  end

  def three_web_failure() do
    Mailgun.Client.send_email @config,
      to: "ali@evercam.io",
      subject: "Three.ie connection failure",
      from: @from,
      bcc: "junaid@evercam.io",
      html: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "three_web_failure.html", year: @year),
      text: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "three_web_failure.txt", year: @year)
  end

  def forgot_password(to, token) do
    Mailgun.Client.send_email @config,
      to: to,
      subject: "EdgeCommander Password Reset",
      from: @from,
      html: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "forgot_password.html", token: token),
      text: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "forgot_password.txt", token: token)
  end

  def signup_email_on_share(to, token, from_user) do
    Mailgun.Client.send_email @config,
      to: to,
      subject: "EdgeCommander Account Sharing",
      from: @from,
      html: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "account_sharing.html", token: token, from_user: from_user),
      text: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "account_sharing.txt", token: token, from_user: from_user)
  end

  def daily_sms_usage_alert(current_date, senders, number, total_sms) do
    Mailgun.Client.send_email @config,
      to: Enum.join(senders, ","),
      subject: "Daily SMS usage alert of #{number}",
      from: @from,
      html: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "daily_sms_alert.html", number: number, total_sms: total_sms, current_date: current_date),
      text: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "daily_sms_alert.txt", number: number, total_sms: total_sms, current_date: current_date)
  end

  def monthly_sms_usage_alert(last_bill_date, senders, number, total_sms) do
    Mailgun.Client.send_email @config,
      to: Enum.join(senders, ","),
      subject: "Monthly SMS usage alert of #{number}",
      from: @from,
      html: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "monthly_sms_alert.html", number: number, total_sms: total_sms, last_bill_date: last_bill_date),
      text: Phoenix.View.render_to_string(EdgeCommanderWeb.EmailView, "monthly_sms_alert.txt", number: number, total_sms: total_sms, last_bill_date: last_bill_date)
  end
end