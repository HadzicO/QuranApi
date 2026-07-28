# Quran API - Admin Panel & CMS Documentation

## Overview

The Quran API Admin Panel is a comprehensive content management system for managing Quran translations, tafsir, audio, topics, and user permissions. It features JWT-based authentication, role-based access control, approval workflows, version history, audit logging, and notifications.

## Features

- ✅ JWT Authentication with access & refresh tokens
- ✅ Role-Based Access Control (Admin, Editor, Readonly)
- ✅ User Management
- ✅ Approval Workflow for content changes
- ✅ Version History tracking
- ✅ Audit Logging
- ✅ Notifications System
- ✅ API Key Management
- ✅ Dashboard with Statistics
- ✅ Password Hashing with Argon2

## Architecture

### Database Tables

1. **users** - User accounts with authentication
2. **revisions** - Content version history with approval workflow
3. **audit_logs** - Complete audit trail of all actions
4. **notifications** - User notifications
5. **api_keys** - API key management

### Contexts

- **QuranApi.Auth** - Authentication and user management
- **QuranApi.Admin** - Admin operations (revisions, audit logs, notifications, API keys)
- **QuranApi.Quran** - Quran content management (existing)

### Authentication

- **Guardian** - JWT token generation and validation
- **Argon2** - Password hashing
- **Plugs** - AuthPipeline, EnsureRole, EnsureActive

## User Roles

### Admin

**Can:**
- Manage all users
- Create/delete editors
- Reset passwords
- Approve/reject editor submissions
- Publish content changes
- Restore previous versions
- View audit logs
- Manage API keys
- View dashboard statistics
- Manage all content

**Cannot:**
- Modify original Arabic Quran text (protected)

### Editor

**Can:**
- Add/edit translations
- Add/edit tafsir
- Add/edit audio URLs
- Manage verse topics
- Submit changes for approval
- Save drafts
- Preview changes
- Search content

**Cannot:**
- Delete users
- Change permissions
- Publish directly (requires approval)
- Delete original Quran text
- Change system settings

### Readonly (Optional)

**Can:**
- View content
- View statistics

**Cannot:**
- Make any changes

## API Endpoints

### Authentication

#### Login
```http
POST /admin/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "SecurePassword123"
}

Response:
{
  "data": {
    "user": {
      "id": 1,
      "email": "admin@example.com",
      "role": "admin",
      "status": "active",
      "first_name": "John",
      "last_name": "Doe"
    },
    "tokens": {
      "access_token": "eyJhbGci...",
      "refresh_token": "eyJhbGci..."
    }
  }
}
```

#### Logout
```http
POST /admin/logout
Authorization: Bearer {access_token}

Response:
{
  "message": "Successfully logged out"
}
```

#### Get Current User
```http
GET /admin/me
Authorization: Bearer {access_token}

Response:
{
  "data": {
    "id": 1,
    "email": "admin@example.com",
    "role": "admin",
    "status": "active"
  }
}
```

#### Refresh Token
```http
POST /admin/refresh
Content-Type: application/json

{
  "refresh_token": "eyJhbGci..."
}

Response:
{
  "data": {
    "access_token": "eyJhbGci...",
    "refresh_token": "eyJhbGci..."
  }
}
```

### User Management

#### List Users
```http
GET /admin/users?page=1&per_page=20&role=editor&status=active
Authorization: Bearer {access_token}

Response:
{
  "data": [
    {
      "id": 1,
      "email": "editor@example.com",
      "role": "editor",
      "status": "active",
      "first_name": "Jane",
      "last_name": "Smith"
    }
  ]
}
```

#### Create User (Admin only)
```http
POST /admin/users
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "user": {
    "email": "neweditor@example.com",
    "password": "SecurePassword123",
    "role": "editor",
    "first_name": "New",
    "last_name": "Editor"
  }
}
```

#### Update User
```http
PUT /admin/users/{id}
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "user": {
    "first_name": "Updated",
    "last_name": "Name"
  }
}
```

#### Delete User (Admin only)
```http
DELETE /admin/users/{id}
Authorization: Bearer {access_token}
```

#### Change User Role (Admin only)
```http
PATCH /admin/users/{id}/role
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "role": "admin"
}
```

#### Change User Status (Admin only)
```http
PATCH /admin/users/{id}/status
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "status": "inactive"
}
```

#### Reset User Password (Admin only)
```http
PATCH /admin/users/{id}/password
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "password": "NewSecurePassword123"
}
```

### Dashboard

#### Get Dashboard Statistics
```http
GET /admin/dashboard
Authorization: Bearer {access_token}

Response:
{
  "data": {
    "total_users": 10,
    "active_users": 8,
    "total_revisions": 45,
    "pending_reviews": 5,
    "published_revisions": 35,
    "total_notifications": 12,
    "total_api_keys": 3,
    "total_surahs": 114,
    "total_ayahs": 6236,
    "total_translations": 150,
    "total_topics": 25,
    "total_audio": 200,
    "languages": 10
  }
}
```

### Approval Workflow & Revisions

#### List Revisions
```http
GET /admin/revisions?page=1&per_page=20&status=pending_review
Authorization: Bearer {access_token}

Response:
{
  "data": [
    {
      "id": 1,
      "entity_type": "translation",
      "entity_id": 123,
      "status": "pending_review",
      "old_value": {...},
      "new_value": {...},
      "reason": "Improved translation accuracy",
      "user": {
        "id": 2,
        "email": "editor@example.com",
        "role": "editor"
      },
      "inserted_at": "2026-07-04T10:00:00Z"
    }
  ]
}
```

#### Create Revision
```http
POST /admin/revisions
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "revision": {
    "entity_type": "translation",
    "entity_id": 123,
    "old_value": {
      "text": "Old translation text"
    },
    "new_value": {
      "text": "New improved translation text"
    },
    "reason": "Improved accuracy and clarity",
    "status": "draft"
  }
}
```

#### Submit Revision for Review
```http
POST /admin/revisions/{id}/submit
Authorization: Bearer {access_token}
```

#### Approve Revision (Admin only)
```http
POST /admin/revisions/{id}/approve
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "notes": "Looks good, approved!"
}
```

#### Reject Revision (Admin only)
```http
POST /admin/revisions/{id}/reject
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "notes": "Needs more work on verse 3."
}
```

#### Publish Revision (Admin only)
```http
POST /admin/revisions/{id}/publish
Authorization: Bearer {access_token}
```

### Notifications

#### List User Notifications
```http
GET /admin/notifications?page=1&per_page=20&read=false
Authorization: Bearer {access_token}

Response:
{
  "data": [
    {
      "id": 1,
      "type": "translation_approved",
      "title": "Your translation was approved",
      "message": "Your translation submission has been approved.",
      "read": false,
      "inserted_at": "2026-07-04T10:00:00Z"
    }
  ]
}
```

#### Mark Notification as Read
```http
PATCH /admin/notifications/{id}/read
Authorization: Bearer {access_token}
```

#### Mark All Notifications as Read
```http
POST /admin/notifications/read-all
Authorization: Bearer {access_token}
```

## Approval Workflow

### Workflow States

1. **Draft** - Editor is working on changes
2. **Pending Review** - Submitted for admin review
3. **Approved** - Admin has approved the changes
4. **Rejected** - Admin has rejected with feedback
5. **Published** - Changes are live in the API

### Workflow Process

```
Editor creates revision (Draft)
    ↓
Editor submits for review (Pending Review)
    ↓
Admin reviews
    ↓
    ├─→ Approve (Approved) ─→ Publish (Published)
    └─→ Reject (Rejected) ─→ Editor revises ─→ Resubmit
```

### Notifications

- **Editor Notified When:**
  - Translation/Tafsir approved
  - Translation/Tafsir rejected
  - Comments added by admin

- **Admin Notified When:**
  - New translation submitted
  - New tafsir submitted
  - New editor created

## Security Features

### Authentication
- JWT tokens with 1-hour expiry
- Refresh tokens with 7-day expiry
- Token revocation support

### Password Requirements
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number

### Password Hashing
- Argon2 (industry-standard, secure)

### Authorization
- Role-Based Access Control (RBAC)
- Route-level permission checks
- User status checks (active/inactive)

### Audit Logging
- All administrative actions logged
- User, IP address, timestamp tracked
- Changes recorded with before/after values

## Setup Instructions

### 1. Install Dependencies
```bash
cd QuranApi
mix deps.get
```

### 2. Run Migrations
```bash
mix ecto.migrate
```

### 3. Create Admin User

Create a seed file or use IEx:

```elixir
# In IEx: iex -S mix
QuranApi.Auth.create_user(%{
  email: "admin@example.com",
  password: "SecurePassword123",
  role: "admin",
  first_name: "Admin",
  last_name: "User"
})
```

### 4. Environment Variables

For production, set these environment variables:

```bash
export DATABASE_URL="ecto://user:pass@localhost/quran_api_prod"
export SECRET_KEY_BASE="$(mix phx.gen.secret)"
export GUARDIAN_SECRET_KEY="$(mix phx.gen.secret)"
```

### 5. Start Server
```bash
mix phx.server
```

## Testing

### Authentication Testing

```bash
# Login
curl -X POST http://localhost:4000/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"SecurePassword123"}'

# Use the access_token from response
export TOKEN="eyJhbGci..."

# Access protected endpoint
curl http://localhost:4000/admin/me \
  -H "Authorization: Bearer $TOKEN"
```

### Create Test Users

```elixir
# Admin
QuranApi.Auth.create_user(%{
  email: "admin@quranapi.com",
  password: "Admin123!",
  role: "admin",
  first_name: "Admin",
  last_name: "User"
})

# Editor
QuranApi.Auth.create_user(%{
  email: "editor@quranapi.com",
  password: "Editor123!",
  role: "editor",
  first_name: "Editor",
  last_name: "User"
})
```

## Database Schema

### Users Table
```sql
id              SERIAL PRIMARY KEY
email           VARCHAR NOT NULL UNIQUE
password_hash   VARCHAR NOT NULL
role            VARCHAR NOT NULL DEFAULT 'editor'
status          VARCHAR NOT NULL DEFAULT 'active'
first_name      VARCHAR
last_name       VARCHAR
last_login_at   TIMESTAMP
last_login_ip   VARCHAR
inserted_at     TIMESTAMP NOT NULL
updated_at      TIMESTAMP NOT NULL
```

### Revisions Table
```sql
id              SERIAL PRIMARY KEY
user_id         INTEGER REFERENCES users(id)
entity_type     VARCHAR NOT NULL
entity_id       INTEGER NOT NULL
status          VARCHAR NOT NULL DEFAULT 'draft'
old_value       JSONB
new_value       JSONB NOT NULL
reason          TEXT
reviewed_by_id  INTEGER REFERENCES users(id)
reviewed_at     TIMESTAMP
review_notes    TEXT
published_at    TIMESTAMP
inserted_at     TIMESTAMP NOT NULL
updated_at      TIMESTAMP NOT NULL
```

### Audit Logs Table
```sql
id              SERIAL PRIMARY KEY
user_id         INTEGER REFERENCES users(id)
action          VARCHAR NOT NULL
entity_type     VARCHAR NOT NULL
entity_id       INTEGER
changes         JSONB
ip_address      VARCHAR
user_agent      VARCHAR
inserted_at     TIMESTAMP NOT NULL
```

### Notifications Table
```sql
id                  SERIAL PRIMARY KEY
user_id             INTEGER REFERENCES users(id) NOT NULL
type                VARCHAR NOT NULL
title               VARCHAR NOT NULL
message             TEXT NOT NULL
related_entity_type VARCHAR
related_entity_id   INTEGER
read                BOOLEAN DEFAULT FALSE NOT NULL
read_at             TIMESTAMP
inserted_at         TIMESTAMP NOT NULL
```

### API Keys Table
```sql
id              SERIAL PRIMARY KEY
user_id         INTEGER REFERENCES users(id)
key_hash        VARCHAR NOT NULL UNIQUE
name            VARCHAR NOT NULL
description     TEXT
status          VARCHAR NOT NULL DEFAULT 'active'
last_used_at    TIMESTAMP
last_used_ip    VARCHAR
expires_at      TIMESTAMP
inserted_at     TIMESTAMP NOT NULL
updated_at      TIMESTAMP NOT NULL
```

## Best Practices

### For Editors

1. **Always save drafts** before submitting for review
2. **Provide clear reasons** for changes in the revision
3. **Never modify** the original Arabic Quran text
4. **Test translations** thoroughly before submission
5. **Respond to feedback** from admins promptly

### For Admins

1. **Review changes carefully** before approving
2. **Provide constructive feedback** when rejecting
3. **Keep audit logs secure** and review regularly
4. **Manage user permissions** appropriately
5. **Monitor suspicious activities** via audit logs

## Future Enhancements

Potential additions for future versions:

- [ ] Two-factor authentication (2FA)
- [ ] Email notifications
- [ ] Advanced search in admin panel
- [ ] Bulk operations support
- [ ] Export/import functionality
- [ ] Real-time collaboration features
- [ ] Mobile app for content management
- [ ] Advanced analytics dashboard
- [ ] Rate limiting per user/API key
- [ ] Content scheduling for future publish

## Troubleshooting

### Common Issues

**Issue:** "Invalid credentials" error when logging in
- Check email/password are correct
- Verify user status is "active"
- Check database connection

**Issue:** "Insufficient permissions" error
- Verify user role has required permissions
- Check JWT token is valid
- Ensure token hasn't expired

**Issue:** Revision approval fails
- Ensure user has admin role
- Verify revision status is "pending_review"
- Check for database constraints

## Support

For issues or questions:
- Create an issue on GitHub
- Email: support@quranapi.com
- Documentation: https://docs.quranapi.com

## License

This admin panel is part of the Quran API project. See LICENSE file for details.
