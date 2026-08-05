defmodule QuranApiWeb.Plugs.AuthPipeline do
  @moduledoc """
  Guardian pipeline for JWT authentication.
  """
  use Guardian.Plug.Pipeline,
    otp_app: :quran_api,
    module: QuranApi.Auth.Guardian,
    error_handler: QuranApiWeb.Plugs.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
