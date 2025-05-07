defmodule QuranApiWeb.Router do
  use QuranApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", QuranApiWeb do
    pipe_through :api

    get "/quotes", QuotesController, :get_random_quote
    get "/quotes/:id", QuotesController, :show
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:quran_api, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
