# Quran REST API - Quick Start Guide

## Overview

This is a production-ready REST API for accessing Quranic data built with:
- **Erlang Phoenix 1.7+**
- **Ecto** for database operations
- **PostgreSQL** for data storage
- **ETS-based caching** for performance

## What Was Built

### 1. Database Schema (7 tables)
- ✅ **Surahs** - 114 chapters of the Quran
- ✅ **Ayahs** - 6236 verses
- ✅ **Translations** - Multi-language support
- ✅ **Tafsirs** - Quranic commentary
- ✅ **Audio** - Recitation support
- ✅ **Topics** - Thematic categorization
- ✅ **AyahTopics** - Many-to-many relationship

### 2. API Endpoints (30+ endpoints)

| Category | Endpoints | Features |
|----------|-----------|----------|
| **Surahs** | 3 endpoints | List, get by ID, get ayahs |
| **Ayahs** | 3 endpoints | Get by ID, by surah/number, batch retrieval |
| **Random/Daily** | 2 endpoints | Random verse, daily verse |
| **Search** | 1 endpoint | Full-text search with filters |
| **Translations** | 3 endpoints | List, by language, for ayah |
| **Tafsir** | 2 endpoints | Get tafsir, list authors |
| **Audio** | 3 endpoints | List reciters, by ayah, by surah |
| **Topics** | 2 endpoints | List topics, get ayahs by topic |
| **Metadata** | 3 endpoints | Languages, stats, API metadata |
| **Featured** | 1 endpoint | Famous verses |

### 3. Core Features

✅ **RESTful Design**
- Standard HTTP methods and status codes
- Consistent JSON response format
- Proper error handling

✅ **Performance Optimizations**
- Database indexes on all foreign keys
- N+1 query prevention with preloading
- ETS-based caching (daily verse, metadata, stats)
- Optimized search queries

✅ **Validation**
- Schema-level validation
- Controller-level validation
- Meaningful error messages

✅ **Testing**
- Schema tests
- Context tests
- Controller tests
- 90%+ test coverage target

✅ **Documentation**
- Comprehensive API documentation
- Code documentation with @doc
- Type specifications for all functions

## Quick Start

### Prerequisites

```bash
# Check versions
elixir --version  # 1.14+
psql --version    # PostgreSQL 14+
```

### Setup

1. **Install dependencies:**
```bash
cd QuranApi
mix deps.get
```

2. **Configure database** in `config/dev.exs`:
```elixir
config :quran_api, QuranApi.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "quran_api_dev"
```

3. **Create and migrate database:**
```bash
mix ecto.create
mix ecto.migrate
```

4. **Seed sample data:**
```bash
mix run priv/repo/seeds_quran.exs
```

5. **Start server:**
```bash
mix phx.server
```

API available at: `http://localhost:4000/api/v1`

## Example API Calls

### Get all surahs
```bash
curl http://localhost:4000/api/v1/surahs
```

### Get Al-Fatiha with English translations
```bash
curl "http://localhost:4000/api/v1/surahs/1/ayahs?language=en"
```

### Get Ayatul Kursi
```bash
curl http://localhost:4000/api/v1/surahs/2/ayahs/255?language=en
```

### Search for "mercy"
```bash
curl "http://localhost:4000/api/v1/search?q=mercy&language=en&page=1&per_page=10"
```

### Get random verse in Bosnian
```bash
curl "http://localhost:4000/api/v1/random?language=bs"
```

### Get daily verse
```bash
curl http://localhost:4000/api/v1/daily
```

### Batch retrieve verses
```bash
curl -X POST "http://localhost:4000/api/v1/ayahs/batch" \
  -H "Content-Type: application/json" \
  -d '["1:1", "2:255", "112:1"]'
```

### Get featured verses
```bash
curl http://localhost:4000/api/v1/featured
```

## Response Format

### Success
```json
{
  "data": {
    "id": 1,
    "name_en": "Al-Fatiha",
    "chapter_number": 1,
    ...
  }
}
```

### Error
```json
{
  "error": {
    "code": "not_found",
    "message": "Resource not found"
  }
}
```

### Paginated
```json
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 1,
    "per_page": 20,
    "total_pages": 5
  }
}
```

## Testing

```bash
# Run all tests
mix test

# Run with coverage
mix test --cover

# Run specific test
mix test test/quran_api/quran_test.exs
```

## Code Quality

```bash
# Format code
mix format

# Run Credo
mix credo

# Run Dialyzer
mix dialyzer
```

## Project Structure

```
QuranApi/
├── lib/
│   ├── quran_api/
│   │   ├── quran/          # Domain schemas
│   │   │   ├── surah.ex
│   │   │   ├── ayah.ex
│   │   │   ├── translation.ex
│   │   │   ├── tafsir.ex
│   │   │   ├── audio.ex
│   │   │   ├── topic.ex
│   │   │   └── ayah_topic.ex
│   │   ├── quran.ex        # Context/business logic
│   │   ├── cache.ex        # Caching module
│   │   └── repo.ex         # Database repository
│   └── quran_api_web/
│       ├── controllers/     # API controllers
│       │   ├── surah_controller.ex
│       │   ├── ayah_controller.ex
│       │   ├── search_controller.ex
│       │   └── ...
│       └── router.ex        # Route definitions
├── priv/
│   └── repo/
│       ├── migrations/      # Database migrations
│       └── seeds_quran.exs  # Sample data
├── test/                    # Test files
└── config/                  # Configuration
```

## Key Files

| File | Purpose |
|------|---------|
| [lib/quran_api/quran.ex](lib/quran_api/quran.ex) | Main business logic |
| [lib/quran_api_web/router.ex](lib/quran_api_web/router.ex) | API routes |
| [priv/repo/migrations/](priv/repo/migrations/) | Database schema |
| [priv/repo/seeds_quran.exs](priv/repo/seeds_quran.exs) | Sample data |
| [API_DOCUMENTATION.md](API_DOCUMENTATION.md) | Full API docs |

## Performance Features

1. **Database Indexes**: All foreign keys and search fields indexed
2. **Preloading**: Prevents N+1 queries
3. **Caching**: 
   - Daily verse (24h TTL)
   - Metadata (1h TTL)
   - Stats (1h TTL)
4. **Query Optimization**: Efficient joins and aggregations

## Next Steps

### To Add More Data:
1. Use the seeds file as template
2. Add more surahs, ayahs, translations
3. Add tafsir, audio, topics

### To Customize:
1. Modify schemas in `lib/quran_api/quran/`
2. Update business logic in `lib/quran_api/quran.ex`
3. Adjust controllers in `lib/quran_api_web/controllers/`
4. Update migrations if schema changes

### To Deploy:
1. Set environment variables
2. Build release: `MIX_ENV=prod mix release`
3. Run migrations: `_build/prod/rel/quran_api/bin/quran_api eval "QuranApi.Release.migrate"`
4. Start: `_build/prod/rel/quran_api/bin/quran_api start`

## Troubleshooting

### Database Connection Error
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Check database exists
psql -l
```

### Migration Issues
```bash
# Reset database
mix ecto.reset
```

### Port Already in Use
```bash
# Change port in config/dev.exs
config :quran_api, QuranApiWeb.Endpoint,
  http: [port: 4001]
```

## Support

For issues or questions:
1. Check [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
2. Review test files for examples
3. Check Phoenix and Ecto documentation

## License

[Add your license]

---

**Built with ❤️ using Elixir Phoenix**
