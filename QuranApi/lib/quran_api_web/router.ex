defmodule QuranApiWeb.Router do
  use QuranApiWeb, :router

  alias QuranApiWeb.Plugs.{AuthPlug, RolePlug}

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: QuranApi.Guardian,
      error_handler: QuranApiWeb.AuthErrorHandler

    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource, allow_blank: true
  end

  pipeline :authenticated do
    plug AuthPlug
  end

  pipeline :admin_only do
    plug RolePlug, ["admin"]
  end

  pipeline :content_manager do
    plug RolePlug, ["admin", "content_writer", "content_reviewer"]
  end

  scope "/v1", QuranApiWeb do
    pipe_through :api

    get "/quotes", QuotesController, :get_random_quote
    get "/quotes/:id", QuotesController, :get_quote_with_translation
    post "/chapters", ChaptersController, :get_chapter_by_name
  end

  scope "/v1", QuranApiWeb do
    pipe_through [:api, :auth]

    post "/login", AuthController, :login
    post "/logout", AuthController, :logout
  end

  scope "/v1/admin", QuranApiWeb do
    pipe_through [:api, :auth, :authenticated, :admin_only]

    # Admin-only routes
    resources "/users", UserController
  end

  scope "/v1/app", QuranApiWeb do
    pipe_through [:api, :auth, :authenticated, :content_manager]

    # Content management routes
    # Add your content routes here
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:quran_api, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
