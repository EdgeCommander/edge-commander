defmodule EdgeCommander.EcMailer do
  use Phoenix.Swoosh, view: EdgeCommanderWeb.EmailView

  @from "support@edgecommander.com"
  @year Calendar.DateTime.now_utc |> Calendar.Strftime.strftime!("%Y")

  def usage_monitoring(senders, usage, number, volume_used, allowance, name, addon) do
    new()
    |> from(@from)
    |> to(senders)
    |> bcc(["junaid@evercam.io", "ali@evercam.io"])
    |> subject("Data usage alert (#{usage}% of #{String.trim(addon, " Broadband")}) on SIM #{number} (#{name})")
    |> render_body("usage_monitoring.html", %{usage: usage, number: number, volume_used: volume_used, allowance: allowance, name: name, addon: addon})
    |> EdgeCommander.Mailer.deliver
  end

  def send_email_for_raid(res, server) do
    new()
    |> from(@from)
    |> to("junaid@evercam.io")
    |> subject("RAID status for your server: #{server.ip}")
    |> render_body("send_email_for_raid.html", %{res: res})
    |> EdgeCommander.Mailer.deliver
  end

  def three_web_failure() do
    new()
    |> from(@from)
    |> to("ali@evercam.io")
    |> bcc("junaid@evercam.io")
    |> subject("Three.ie connection failure")
    |> render_body("three_web_failure.html", %{year: @year})
    |> EdgeCommander.Mailer.deliver
  end

  def forgot_password(to, token) do
    new()
    |> from(@from)
    |> to(to)
    |> subject("EdgeCommander Password Reset")
    |> render_body("forgot_password.html", %{token: token})
    |> EdgeCommander.Mailer.deliver
  end

  def signup_email_on_share(to, token, from_user) do
    new()
    |> from(@from)
    |> to(to)
    |> subject("EdgeCommander Account Sharing")
    |> render_body("account_sharing.html", %{token: token, from_user: from_user})
    |> EdgeCommander.Mailer.deliver
  end

  def daily_sms_usage_alert(current_date, senders, number, total_sms) do
    new()
    |> from(@from)
    |> to(senders)
    |> subject("Daily SMS usage alert of #{number}")
    |> render_body("daily_sms_alert.html", %{number: number, total_sms: total_sms, current_date: current_date})
    |> EdgeCommander.Mailer.deliver
  end

  def monthly_sms_usage_alert(last_bill_date, senders, number, total_sms) do
    new()
    |> from(@from)
    |> to(senders)
    |> subject("Monthly SMS usage alert of #{number}")
    |> render_body("monthly_sms_alert.html", %{number: number, total_sms: total_sms, last_bill_date: last_bill_date})
    |> EdgeCommander.Mailer.deliver
  end
end
