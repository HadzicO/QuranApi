defmodule QuranApi.Guardian do
  @moduledoc """
  Guardian implementation module for QuranApi.

  This module integrates the Guardian library for JWT-based authentication.
  It provides functions to encode and decode user information into JWT tokens.

  ## Functions

    * `subject_for_token/2` - Converts a user struct into a subject string for token generation.
    * `resource_from_claims/1` - Retrieves a user resource from JWT claims, using the subject.

  ## Usage

  This module is typically used as the authentication backend for the QuranApi application.
  """

  use Guardian, otp_app: :quran_api

  alias QuranApi.Accounts

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user!(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
