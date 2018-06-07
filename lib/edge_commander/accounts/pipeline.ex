defmodule EdgeCommander.Accounts.Pipeline do
	use Guardian.Plug.Pipeline, otp_app: :edge_commander
	plug Guardian.Plug.VerifyCookie
	plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
	plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
	plug Guardian.Plug.LoadResource, allow_blank: true
end