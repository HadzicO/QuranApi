# Quran API

A production-ready REST API for accessing Quranic data built with Elixir Phoenix, Ecto, and PostgreSQL.

## Features

- **Complete Quran Data**: All 114 surahs and 6236 ayahs
- **Translations**: Support for multiple languages and translators
- **Tafsir**: Quranic exegesis/commentary from various scholars
- **Audio**: Recitation from multiple reciters
- **Topics**: Thematic categorization of verses
- **Search**: Full-text search in Arabic text and translations
- **Random & Daily Verses**: Get random or deterministic daily verses
- **Batch Retrieval**: Fetch multiple verses in a single request
- **Caching**: Optimized performance with ETS-based caching
- **RESTful Design**: Follows REST best practices
- **Comprehensive Tests**: 90%+ test coverage

## Prerequisites

- Elixir 1.14+ and Erlang/OTP 25+
- PostgreSQL 14+
- (Optional) asdf for version management

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd QuranApi
```

2. Install dependencies:
```bash
mix deps.get
```

3. Configure database in `config/dev.exs`:
```elixir
config :quran_api, QuranApi.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "quran_api_dev"
```

4. Create and migrate database:
```bash
mix ecto.setup
```

5. (Optional) Seed database with sample data:
```bash
mix run priv/repo/seeds.exs
```

6. Start the server:
```bash
mix phx.server
```

The API will be available at `http://localhost:4000`

## API Endpoints

### Surahs (Chapters)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/surahs` | List all surahs |
| GET | `/api/v1/surahs/:id` | Get a specific surah |
| GET | `/api/v1/surahs/:id/ayahs` | Get all ayahs in a surah |

**Query Parameters for `/surahs`:**
- `limit` - Number of results (default: 114)
- `offset` - Pagination offset (default: 0)
- `order_by` - Field to order by (default: chapter_number)
- `order` - Order direction: asc/desc (default: asc)

**Query Parameters for `/surahs/:id/ayahs`:**
- `limit` - Number of results (default: 300)
- `offset` - Pagination offset (default: 0)
- `language` - Filter translations by language code
- `translator` - Filter by specific translator

### Ayahs (Verses)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/ayahs/:id` | Get a specific ayah by ID |
| GET | `/api/v1/surahs/:surah_id/ayahs/:ayah_number` | Get ayah by surah and number |
| POST | `/api/v1/ayahs/batch` | Get multiple ayahs by references |

**Batch Request Example:**
```json
POST /api/v1/ayahs/batch
["2:255", "36:58", "112:1"]
```

### Random & Daily

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/random` | Get a random ayah |
| GET | `/api/v1/daily` | Get the daily ayah |

**Query Parameters:**
- `language` - Language code for translations
- `translator` - Specific translator
- `topic` - Filter by topic slug (random only)
- `surah` - Filter by surah ID (random only)

### Search

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/search` | Search ayahs and translations |

**Query Parameters:**
- `q` - Search query (required)
- `language` - Search in specific language
- `translator` - Filter by translator
- `surah` - Filter by surah ID
- `topic` - Filter by topic slug
- `revelation` - Filter by revelation type (Meccan/Medinan)
- `page` - Page number (default: 1)
- `per_page` - Results per page (default: 20)

### Translations

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/translations` | List all translators |
| GET | `/api/v1/translations/:language` | Get translations by language |
| GET | `/api/v1/ayahs/:id/translations` | Get translations for an ayah |

### Tafsir

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/ayahs/:id/tafsir` | Get tafsir for an ayah |
| GET | `/api/v1/tafsir/authors` | List all tafsir authors |

**Query Parameters:**
- `language` - Filter by language code
- `author` - Filter by author name

### Audio

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/reciters` | List all reciters |
| GET | `/api/v1/audio/:id` | Get audio for an ayah |
| GET | `/api/v1/surahs/:id/audio` | Get audio for all ayahs in a surah |

**Query Parameters:**
- `reciter` - Filter by specific reciter

### Topics

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/topics` | List all topics |
| GET | `/api/v1/topics/:slug` | Get ayahs for a topic |

**Query Parameters for `/topics/:slug`:**
- `limit` - Number of results (default: 100)
- `offset` - Pagination offset
- `language` - Language code for translations
- `translator` - Specific translator

**Example Topics:**
- patience
- prayer
- fasting
- charity
- forgiveness
- paradise
- hell

### Metadata

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/languages` | List available languages |
| GET | `/api/v1/stats` | Database statistics |
| GET | `/api/v1/metadata` | API metadata |

### Featured

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/featured` | Get famous/featured verses |

**Includes:**
- Ayatul Kursi (2:255)
- Last two verses of Al-Baqarah (2:285-286)
- Surah Al-Ikhlas (112:1-4)
- Surah Al-Falaq (113:1-5)
- Surah An-Nas (114:1-6)

## Response Format

### Success Response

```json
{
  "data": {
    // Response data
  }
}
```

### Error Response

```json
{
  "error": {
    "code": "not_found",
    "message": "Resource not found"
  }
}
```

### Validation Error Response

```json
{
  "error": {
    "code": "validation_error",
    "message": "Validation failed",
    "details": {
      "field_name": ["error message"]
    }
  }
}
```

### Paginated Response

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

## Example Requests

### Get Ayatul Kursi with English translation

```bash
curl "http://localhost:4000/api/v1/surahs/2/ayahs/255?language=en"
```

### Search for "mercy" in English translations

```bash
curl "http://localhost:4000/api/v1/search?q=mercy&language=en&page=1&per_page=10"
```

### Get multiple ayahs

```bash
curl -X POST "http://localhost:4000/api/v1/ayahs/batch" \
  -H "Content-Type: application/json" \
  -d '["2:255", "112:1", "113:1"]'
```

### Get daily verse in Bosnian

```bash
curl "http://localhost:4000/api/v1/daily?language=bs"
```

## Testing

Run all tests:
```bash
mix test
```

Run tests with coverage:
```bash
mix test --cover
```

Run specific test file:
```bash
mix test test/quran_api/quran_test.exs
```

## Database Schema

### Surahs
- `id` - Primary key
- `chapter_number` - Chapter number (1-114)
- `name_ar` - Arabic name
- `name_en` - English name
- `name_bs` - Bosnian name
- `revelation_type` - Meccan or Medinan
- `verses_count` - Number of verses

### Ayahs
- `id` - Primary key
- `surah_id` - Foreign key to surahs
- `ayah_number` - Verse number within surah
- `global_number` - Global verse number (1-6236)
- `arabic_text` - Arabic text

### Translations
- `id` - Primary key
- `ayah_id` - Foreign key to ayahs
- `language_code` - ISO 639-1 language code
- `translator` - Translator name
- `text` - Translated text

### Tafsirs
- `id` - Primary key
- `ayah_id` - Foreign key to ayahs
- `author` - Author name
- `language_code` - ISO 639-1 language code
- `text` - Tafsir text

### Audio
- `id` - Primary key
- `ayah_id` - Foreign key to ayahs
- `reciter` - Reciter name
- `audio_url` - URL to audio file
- `duration` - Duration in seconds

### Topics
- `id` - Primary key
- `slug` - URL-friendly identifier
- `name` - Topic name

### AyahTopics
- `id` - Primary key
- `ayah_id` - Foreign key to ayahs
- `topic_id` - Foreign key to topics

## Performance Optimizations

1. **Database Indexes**: All foreign keys and frequently queried fields are indexed
2. **Preloading**: Associations are preloaded to avoid N+1 queries
3. **Caching**: ETS-based caching for:
   - Daily verse (24-hour TTL)
   - Metadata (1-hour TTL)
   - Statistics (1-hour TTL)
   - Language list (1-hour TTL)
4. **Query Optimization**: Efficient queries with proper use of joins and aggregations

## Code Quality

- **Typespecs**: All public functions have type specifications
- **Documentation**: Comprehensive @doc comments
- **Credo**: Static code analysis
- **Dialyzer**: Type checking
- **Test Coverage**: 90%+ code coverage

## Development

### Code Formatting

```bash
mix format
```

### Static Analysis

```bash
mix credo
mix dialyzer
```

### Database Management

```bash
# Create database
mix ecto.create

# Run migrations
mix ecto.migrate

# Rollback migration
mix ecto.rollback

# Reset database
mix ecto.reset

# Drop database
mix ecto.drop
```

## Production Deployment

1. Set production environment variables:
```bash
export DATABASE_URL="postgresql://user:pass@host/dbname"
export SECRET_KEY_BASE="your-secret-key"
export PHX_HOST="your-domain.com"
```

2. Build release:
```bash
MIX_ENV=prod mix release
```

3. Run migrations:
```bash
_build/prod/rel/quran_api/bin/quran_api eval "QuranApi.Release.migrate"
```

4. Start the server:
```bash
_build/prod/rel/quran_api/bin/quran_api start
```

## Docker Support

Build and run with Docker:

```bash
docker build -t quran-api .
docker run -p 4000:4000 -e DATABASE_URL=postgresql://... quran-api
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for your changes
4. Ensure all tests pass
5. Submit a pull request

## License

[Add your license here]

## Support

For issues and questions, please open an issue on GitHub.
