# Admin Panel Quick Start Guide

## Step 1: Install Dependencies

```bash
cd QuranApi
mix deps.get
```

## Step 2: Run Migrations

```bash
mix ecto.migrate
```

This will create the following tables:
- users
- audit_logs
- revisions
- notifications
- api_keys

## Step 3: Create Admin User

Use the handy setup task:

```bash
mix admin.setup
```

Or manually via IEx:

```bash
iex -S mix
```

```elixir
QuranApi.Auth.create_user(%{
  email: "admin@quranapi.com",
  password: "Admin123!Test",
  role: "admin",
  first_name: "Admin",
  last_name: "User"
})
```

## Step 4: Start the Server

```bash
mix phx.server
```

## Step 5: Test Authentication

### Login

```bash
curl -X POST http://localhost:4000/admin/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@quranapi.com",
    "password": "Admin123!Test"
  }'
```

You'll receive a response like:

```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "admin@quranapi.com",
      "role": "admin",
      "status": "active"
    },
    "tokens": {
      "access_token": "eyJhbGci...",
      "refresh_token": "eyJhbGci..."
    }
  }
}
```

### Store Token

```bash
export TOKEN="<your-access-token>"
```

### Get Current User

```bash
curl http://localhost:4000/admin/me \
  -H "Authorization: Bearer $TOKEN"
```

### Get Dashboard Stats

```bash
curl http://localhost:4000/admin/dashboard \
  -H "Authorization: Bearer $TOKEN"
```

### Create an Editor

```bash
curl -X POST http://localhost:4000/admin/users \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "editor@quranapi.com",
      "password": "Editor123!Test",
      "role": "editor",
      "first_name": "Editor",
      "last_name": "User"
    }
  }'
```

## Step 6: Create a Revision (as Editor)

First, login as the editor:

```bash
curl -X POST http://localhost:4000/admin/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "editor@quranapi.com",
    "password": "Editor123!Test"
  }'

export EDITOR_TOKEN="<editor-access-token>"
```

Create a revision:

```bash
curl -X POST http://localhost:4000/admin/revisions \
  -H "Authorization: Bearer $EDITOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "revision": {
      "entity_type": "translation",
      "entity_id": 1,
      "new_value": {
        "text": "Updated translation text"
      },
      "reason": "Improved translation accuracy"
    }
  }'
```

Submit for review:

```bash
curl -X POST http://localhost:4000/admin/revisions/1/submit \
  -H "Authorization: Bearer $EDITOR_TOKEN"
```

## Step 7: Approve Revision (as Admin)

```bash
curl -X POST http://localhost:4000/admin/revisions/1/approve \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "notes": "Looks good!"
  }'
```

Publish the revision:

```bash
curl -X POST http://localhost:4000/admin/revisions/1/publish \
  -H "Authorization: Bearer $TOKEN"
```

## Step 8: Check Notifications

```bash
curl http://localhost:4000/admin/notifications \
  -H "Authorization: Bearer $EDITOR_TOKEN"
```

## Common Commands

### List all users
```bash
curl "http://localhost:4000/admin/users?page=1&per_page=20" \
  -H "Authorization: Bearer $TOKEN"
```

### List pending revisions
```bash
curl "http://localhost:4000/admin/revisions?status=pending_review" \
  -H "Authorization: Bearer $TOKEN"
```

### Mark all notifications as read
```bash
curl -X POST http://localhost:4000/admin/notifications/read-all \
  -H "Authorization: Bearer $TOKEN"
```

### Change user role
```bash
curl -X PATCH http://localhost:4000/admin/users/2/role \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": "readonly"}'
```

### Reset user password
```bash
curl -X PATCH http://localhost:4000/admin/users/2/password \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"password": "NewPassword123!"}'
```

## Next Steps

1. Read the full [ADMIN_PANEL.md](ADMIN_PANEL.md) documentation
2. Implement content management controllers for:
   - Translations (GET /admin/translations, POST /admin/translations, etc.)
   - Tafsir (GET /admin/tafsir, POST /admin/tafsir, etc.)
   - Topics (GET /admin/topics, POST /admin/topics, etc.)
   - Audio (GET /admin/audio, POST /admin/audio, etc.)
   - Featured Verses (GET /admin/featured, POST /admin/featured, etc.)
3. Build a frontend admin dashboard using React, Vue, or Phoenix LiveView
4. Add automated tests
5. Set up CI/CD pipeline

## Troubleshooting

### Token expired error
Tokens expire after 1 hour. Use the refresh token to get a new access token:

```bash
curl -X POST http://localhost:4000/admin/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "<your-refresh-token>"
  }'
```

### Permission denied
Ensure you're using the correct role:
- Only admins can create/delete users
- Only admins can approve/reject revisions
- Editors can create and submit revisions

### Database errors
Run migrations again:
```bash
mix ecto.reset
```

## Production Deployment

For production, set these environment variables:

```bash
export DATABASE_URL="ecto://user:pass@host/database"
export SECRET_KEY_BASE="$(mix phx.gen.secret)"
export GUARDIAN_SECRET_KEY="$(mix phx.gen.secret)"
export PORT=4000
export PHX_HOST="quranapi.com"
```

Build release:

```bash
MIX_ENV=prod mix release
```

Run in production:

```bash
PHX_SERVER=true _build/prod/rel/quran_api/bin/quran_api start
```

## Resources

- Full Documentation: [ADMIN_PANEL.md](ADMIN_PANEL.md)
- API Documentation: [README.md](README.md)
- GitHub: https://github.com/yourusername/QuranApi
