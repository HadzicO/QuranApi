defmodule QuranApiWeb.CorsController do
  use QuranApiWeb, :controller

  def preflight(conn, _params) do
    # CORS headers are already set by the CORS plug
    # Just return 204 No Content for OPTIONS preflight requests
    send_resp(conn, :no_content, "")
  end
end
