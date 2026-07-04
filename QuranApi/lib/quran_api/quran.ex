defmodule QuranApi.Quran do
  @moduledoc """
  The Quran context provides functions for interacting with Quranic data.
  """

  import Ecto.Query, warn: false
  alias QuranApi.Repo
  alias QuranApi.Quran.{Surah, Ayah, Translation, Tafsir, Audio, Topic, AyahTopic}

  # ==================== Surah Functions ====================

  @doc """
  Returns the list of surahs.

  ## Options

    * `:limit` - Maximum number of results to return
    * `:offset` - Number of results to skip
    * `:order_by` - Field to order by (default: :chapter_number)
    * `:order` - Order direction :asc or :desc (default: :asc)

  ## Examples

      iex> list_surahs()
      [%Surah{}, ...]

      iex> list_surahs(limit: 10, offset: 0)
      [%Surah{}, ...]

  """
  @spec list_surahs(keyword()) :: [Surah.t()]
  def list_surahs(opts \\ []) do
    limit = Keyword.get(opts, :limit, 114)
    offset = Keyword.get(opts, :offset, 0)
    order_by = Keyword.get(opts, :order_by, :chapter_number)
    order = Keyword.get(opts, :order, :asc)

    Surah
    |> order_by(^[{order, order_by}])
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  @doc """
  Gets a single surah by ID.

  Returns `nil` if the Surah does not exist.

  ## Examples

      iex> get_surah(1)
      %Surah{}

      iex> get_surah(999)
      nil

  """
  @spec get_surah(integer()) :: Surah.t() | nil
  def get_surah(id), do: Repo.get(Surah, id)

  @doc """
  Gets a single surah by chapter number.

  Returns `nil` if the Surah does not exist.

  ## Examples

      iex> get_surah_by_number(1)
      %Surah{}

  """
  @spec get_surah_by_number(integer()) :: Surah.t() | nil
  def get_surah_by_number(chapter_number) do
    Repo.get_by(Surah, chapter_number: chapter_number)
  end

  @doc """
  Creates a surah.

  ## Examples

      iex> create_surah(%{chapter_number: 1, name_ar: "الفاتحة"})
      {:ok, %Surah{}}

      iex> create_surah(%{})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_surah(map()) :: {:ok, Surah.t()} | {:error, Ecto.Changeset.t()}
  def create_surah(attrs \\ %{}) do
    %Surah{}
    |> Surah.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a surah.
  """
  @spec update_surah(Surah.t(), map()) :: {:ok, Surah.t()} | {:error, Ecto.Changeset.t()}
  def update_surah(%Surah{} = surah, attrs) do
    surah
    |> Surah.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a surah.
  """
  @spec delete_surah(Surah.t()) :: {:ok, Surah.t()} | {:error, Ecto.Changeset.t()}
  def delete_surah(%Surah{} = surah) do
    Repo.delete(surah)
  end

  # ==================== Ayah Functions ====================

  @doc """
  Returns the list of ayahs for a surah.

  ## Options

    * `:limit` - Maximum number of results to return
    * `:offset` - Number of results to skip
    * `:preload` - Associations to preload (e.g., [:translations, :tafsirs])
    * `:language` - Filter translations by language code

  ## Examples

      iex> list_ayahs_by_surah(1)
      [%Ayah{}, ...]

  """
  @spec list_ayahs_by_surah(integer(), keyword()) :: [Ayah.t()]
  def list_ayahs_by_surah(surah_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 300)
    offset = Keyword.get(opts, :offset, 0)
    preload = Keyword.get(opts, :preload, [])
    language = Keyword.get(opts, :language)

    query =
      Ayah
      |> where([a], a.surah_id == ^surah_id)
      |> order_by([a], a.ayah_number)
      |> limit(^limit)
      |> offset(^offset)

    query =
      if language do
        from q in query,
          left_join: t in assoc(q, :translations),
          where: is_nil(t.id) or t.language_code == ^language,
          preload: [translations: t]
      else
        preload(query, ^preload)
      end

    Repo.all(query)
  end

  @doc """
  Gets a single ayah by ID.

  ## Options

    * `:preload` - Associations to preload

  """
  @spec get_ayah(integer(), keyword()) :: Ayah.t() | nil
  def get_ayah(id, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    Ayah
    |> preload(^preload)
    |> Repo.get(id)
  end

  @doc """
  Gets a single ayah by global number.
  """
  @spec get_ayah_by_global_number(integer(), keyword()) :: Ayah.t() | nil
  def get_ayah_by_global_number(global_number, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    Ayah
    |> where([a], a.global_number == ^global_number)
    |> preload(^preload)
    |> Repo.one()
  end

  @doc """
  Gets a single ayah by surah ID and ayah number.

  ## Examples

      iex> get_ayah_by_surah_and_number(1, 1)
      %Ayah{}

  """
  @spec get_ayah_by_surah_and_number(integer(), integer(), keyword()) :: Ayah.t() | nil
  def get_ayah_by_surah_and_number(surah_id, ayah_number, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    Ayah
    |> where([a], a.surah_id == ^surah_id and a.ayah_number == ^ayah_number)
    |> preload(^preload)
    |> Repo.one()
  end

  @doc """
  Parses ayah reference in format "surah:ayah" (e.g., "2:255").

  Returns `{:ok, surah_id, ayah_number}` or `{:error, reason}`.
  """
  @spec parse_ayah_reference(String.t()) :: {:ok, integer(), integer()} | {:error, String.t()}
  def parse_ayah_reference(reference) when is_binary(reference) do
    case String.split(reference, ":") do
      [surah_str, ayah_str] ->
        with {surah_num, ""} <- Integer.parse(surah_str),
             {ayah_num, ""} <- Integer.parse(ayah_str) do
          {:ok, surah_num, ayah_num}
        else
          _ -> {:error, "Invalid ayah reference format"}
        end

      _ ->
        {:error, "Invalid ayah reference format. Expected format: 'surah:ayah'"}
    end
  end

  @doc """
  Gets multiple ayahs by their references.

  ## Examples

      iex> get_ayahs_by_references(["2:255", "36:58"])
      [%Ayah{}, %Ayah{}]

  """
  @spec get_ayahs_by_references([String.t()], keyword()) ::
          {:ok, [Ayah.t()]} | {:error, [String.t()]}
  def get_ayahs_by_references(references, opts \\ []) when is_list(references) do
    preload = Keyword.get(opts, :preload, [])

    results =
      Enum.map(references, fn ref ->
        case parse_ayah_reference(ref) do
          {:ok, surah_num, ayah_num} ->
            case get_surah_by_number(surah_num) do
              nil ->
                {:error, "Surah #{surah_num} not found"}

              surah ->
                case get_ayah_by_surah_and_number(surah.id, ayah_num, preload: preload) do
                  nil -> {:error, "Ayah #{ref} not found"}
                  ayah -> {:ok, ayah}
                end
            end

          {:error, reason} ->
            {:error, reason}
        end
      end)

    errors = Enum.filter(results, &match?({:error, _}, &1))

    if Enum.empty?(errors) do
      {:ok, Enum.map(results, fn {:ok, ayah} -> ayah end)}
    else
      {:error, Enum.map(errors, fn {:error, msg} -> msg end)}
    end
  end

  @doc """
  Creates an ayah.
  """
  @spec create_ayah(map()) :: {:ok, Ayah.t()} | {:error, Ecto.Changeset.t()}
  def create_ayah(attrs \\ %{}) do
    %Ayah{}
    |> Ayah.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an ayah.
  """
  @spec update_ayah(Ayah.t(), map()) :: {:ok, Ayah.t()} | {:error, Ecto.Changeset.t()}
  def update_ayah(%Ayah{} = ayah, attrs) do
    ayah
    |> Ayah.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an ayah.
  """
  @spec delete_ayah(Ayah.t()) :: {:ok, Ayah.t()} | {:error, Ecto.Changeset.t()}
  def delete_ayah(%Ayah{} = ayah) do
    Repo.delete(ayah)
  end

  @doc """
  Gets a random ayah.

  ## Options

    * `:surah_id` - Filter by surah
    * `:topic_slug` - Filter by topic
    * `:preload` - Associations to preload

  """
  @spec get_random_ayah(keyword()) :: Ayah.t() | nil
  def get_random_ayah(opts \\ []) do
    surah_id = Keyword.get(opts, :surah_id)
    topic_slug = Keyword.get(opts, :topic_slug)
    preload = Keyword.get(opts, :preload, [])

    query =
      Ayah
      |> maybe_filter_by_surah(surah_id)
      |> maybe_filter_by_topic(topic_slug)
      |> order_by(fragment("RANDOM()"))
      |> limit(1)
      |> preload(^preload)

    Repo.one(query)
  end

  defp maybe_filter_by_surah(query, nil), do: query
  defp maybe_filter_by_surah(query, surah_id), do: where(query, [a], a.surah_id == ^surah_id)

  defp maybe_filter_by_topic(query, nil), do: query

  defp maybe_filter_by_topic(query, topic_slug) do
    query
    |> join(:inner, [a], at in AyahTopic, on: at.ayah_id == a.id)
    |> join(:inner, [a, at], t in Topic, on: t.id == at.topic_id)
    |> where([a, at, t], t.slug == ^topic_slug)
  end

  @doc """
  Gets the daily ayah for the current UTC date.

  Uses a deterministic algorithm based on the date to ensure
  all users get the same ayah on the same day.
  """
  @spec get_daily_ayah(keyword()) :: Ayah.t() | nil
  def get_daily_ayah(opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    # Get days since epoch
    days_since_epoch = Date.utc_today() |> Date.to_gregorian_days()

    # Get total ayah count
    total_ayahs = Repo.aggregate(Ayah, :count, :id)

    # Calculate which ayah to show (cycles through all ayahs)
    ayah_index = rem(days_since_epoch, total_ayahs)

    Ayah
    |> order_by([a], a.global_number)
    |> offset(^ayah_index)
    |> limit(1)
    |> preload(^preload)
    |> Repo.one()
  end

  # ==================== Translation Functions ====================

  @doc """
  Gets translations for an ayah.

  ## Options

    * `:language_code` - Filter by language
    * `:translator` - Filter by translator

  """
  @spec get_ayah_translations(integer(), keyword()) :: [Translation.t()]
  def get_ayah_translations(ayah_id, opts \\ []) do
    language_code = Keyword.get(opts, :language_code)
    translator = Keyword.get(opts, :translator)

    Translation
    |> where([t], t.ayah_id == ^ayah_id)
    |> maybe_filter_by_language(language_code)
    |> maybe_filter_by_translator(translator)
    |> Repo.all()
  end

  defp maybe_filter_by_language(query, nil), do: query
  defp maybe_filter_by_language(query, lang), do: where(query, [t], t.language_code == ^lang)

  defp maybe_filter_by_translator(query, nil), do: query

  defp maybe_filter_by_translator(query, translator),
    do: where(query, [t], t.translator == ^translator)

  @doc """
  Lists all available languages from translations.
  """
  @spec list_languages() :: [%{language_code: String.t(), count: integer()}]
  def list_languages do
    Translation
    |> group_by([t], t.language_code)
    |> select([t], %{language_code: t.language_code, count: count(t.id)})
    |> order_by([t], t.language_code)
    |> Repo.all()
  end

  @doc """
  Lists all translations for a specific language.
  """
  @spec list_translations_by_language(String.t()) :: [Translation.t()]
  def list_translations_by_language(language_code) do
    Translation
    |> where([t], t.language_code == ^language_code)
    |> preload(:ayah)
    |> Repo.all()
  end

  @doc """
  Lists all available translators.
  """
  @spec list_translators() :: [
          %{translator: String.t(), language_code: String.t(), count: integer()}
        ]
  def list_translators do
    Translation
    |> group_by([t], [t.translator, t.language_code])
    |> select([t], %{
      translator: t.translator,
      language_code: t.language_code,
      count: count(t.id)
    })
    |> order_by([t], [t.language_code, t.translator])
    |> Repo.all()
  end

  @doc """
  Creates a translation.
  """
  @spec create_translation(map()) :: {:ok, Translation.t()} | {:error, Ecto.Changeset.t()}
  def create_translation(attrs \\ %{}) do
    %Translation{}
    |> Translation.changeset(attrs)
    |> Repo.insert()
  end

  # ==================== Tafsir Functions ====================

  @doc """
  Gets tafsirs for an ayah.

  ## Options

    * `:language_code` - Filter by language
    * `:author` - Filter by author

  """
  @spec get_ayah_tafsirs(integer(), keyword()) :: [Tafsir.t()]
  def get_ayah_tafsirs(ayah_id, opts \\ []) do
    language_code = Keyword.get(opts, :language_code)
    author = Keyword.get(opts, :author)

    Tafsir
    |> where([t], t.ayah_id == ^ayah_id)
    |> maybe_filter_tafsir_by_language(language_code)
    |> maybe_filter_by_author(author)
    |> Repo.all()
  end

  defp maybe_filter_tafsir_by_language(query, nil), do: query

  defp maybe_filter_tafsir_by_language(query, lang),
    do: where(query, [t], t.language_code == ^lang)

  defp maybe_filter_by_author(query, nil), do: query
  defp maybe_filter_by_author(query, author), do: where(query, [t], t.author == ^author)

  @doc """
  Lists all available tafsir authors.
  """
  @spec list_tafsir_authors() :: [
          %{author: String.t(), language_code: String.t(), count: integer()}
        ]
  def list_tafsir_authors do
    Tafsir
    |> group_by([t], [t.author, t.language_code])
    |> select([t], %{
      author: t.author,
      language_code: t.language_code,
      count: count(t.id)
    })
    |> order_by([t], [t.language_code, t.author])
    |> Repo.all()
  end

  @doc """
  Creates a tafsir.
  """
  @spec create_tafsir(map()) :: {:ok, Tafsir.t()} | {:error, Ecto.Changeset.t()}
  def create_tafsir(attrs \\ %{}) do
    %Tafsir{}
    |> Tafsir.changeset(attrs)
    |> Repo.insert()
  end

  # ==================== Audio Functions ====================

  @doc """
  Gets audio for an ayah.

  ## Options

    * `:reciter` - Filter by reciter

  """
  @spec get_ayah_audio(integer(), keyword()) :: [Audio.t()]
  def get_ayah_audio(ayah_id, opts \\ []) do
    reciter = Keyword.get(opts, :reciter)

    Audio
    |> where([a], a.ayah_id == ^ayah_id)
    |> maybe_filter_by_reciter(reciter)
    |> Repo.all()
  end

  defp maybe_filter_by_reciter(query, nil), do: query
  defp maybe_filter_by_reciter(query, reciter), do: where(query, [a], a.reciter == ^reciter)

  @doc """
  Gets audio for all ayahs in a surah.
  """
  @spec get_surah_audio(integer(), keyword()) :: [Audio.t()]
  def get_surah_audio(surah_id, opts \\ []) do
    reciter = Keyword.get(opts, :reciter)

    Audio
    |> join(:inner, [au], a in Ayah, on: au.ayah_id == a.id)
    |> where([au, a], a.surah_id == ^surah_id)
    |> maybe_filter_audio_by_reciter(reciter)
    |> order_by([au, a], a.ayah_number)
    |> preload([au, a], ayah: a)
    |> Repo.all()
  end

  defp maybe_filter_audio_by_reciter(query, nil), do: query

  defp maybe_filter_audio_by_reciter(query, reciter),
    do: where(query, [au, a], au.reciter == ^reciter)

  @doc """
  Lists all available reciters.
  """
  @spec list_reciters() :: [%{reciter: String.t(), count: integer()}]
  def list_reciters do
    Audio
    |> group_by([a], a.reciter)
    |> select([a], %{reciter: a.reciter, count: count(a.id)})
    |> order_by([a], a.reciter)
    |> Repo.all()
  end

  @doc """
  Creates audio.
  """
  @spec create_audio(map()) :: {:ok, Audio.t()} | {:error, Ecto.Changeset.t()}
  def create_audio(attrs \\ %{}) do
    %Audio{}
    |> Audio.changeset(attrs)
    |> Repo.insert()
  end

  # ==================== Topic Functions ====================

  @doc """
  Lists all topics.
  """
  @spec list_topics() :: [Topic.t()]
  def list_topics do
    Topic
    |> order_by([t], t.name)
    |> Repo.all()
  end

  @doc """
  Gets a topic by slug.
  """
  @spec get_topic_by_slug(String.t()) :: Topic.t() | nil
  def get_topic_by_slug(slug) do
    Repo.get_by(Topic, slug: slug)
  end

  @doc """
  Gets all ayahs for a topic.

  ## Options

    * `:limit` - Maximum number of results
    * `:offset` - Number of results to skip
    * `:preload` - Associations to preload

  """
  @spec get_ayahs_by_topic(String.t(), keyword()) :: [Ayah.t()]
  def get_ayahs_by_topic(topic_slug, opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)
    offset = Keyword.get(opts, :offset, 0)
    preload = Keyword.get(opts, :preload, [])

    Ayah
    |> join(:inner, [a], at in AyahTopic, on: at.ayah_id == a.id)
    |> join(:inner, [a, at], t in Topic, on: t.id == at.topic_id)
    |> where([a, at, t], t.slug == ^topic_slug)
    |> order_by([a], [a.surah_id, a.ayah_number])
    |> limit(^limit)
    |> offset(^offset)
    |> preload(^preload)
    |> Repo.all()
  end

  @doc """
  Creates a topic.
  """
  @spec create_topic(map()) :: {:ok, Topic.t()} | {:error, Ecto.Changeset.t()}
  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Associates an ayah with a topic.
  """
  @spec add_ayah_to_topic(integer(), integer()) ::
          {:ok, AyahTopic.t()} | {:error, Ecto.Changeset.t()}
  def add_ayah_to_topic(ayah_id, topic_id) do
    %AyahTopic{}
    |> AyahTopic.changeset(%{ayah_id: ayah_id, topic_id: topic_id})
    |> Repo.insert()
  end

  # ==================== Search Functions ====================

  @doc """
  Searches for ayahs and translations.

  ## Options

    * `:q` - Search query (required)
    * `:language` - Filter by language
    * `:translator` - Filter by translator
    * `:surah` - Filter by surah ID
    * `:topic` - Filter by topic slug
    * `:revelation` - Filter by revelation type ("Meccan" or "Medinan")
    * `:page` - Page number (default: 1)
    * `:per_page` - Results per page (default: 20)

  """
  @spec search(keyword()) :: %{
          results: [map()],
          total: integer(),
          page: integer(),
          per_page: integer()
        }
  def search(opts) do
    query = Keyword.get(opts, :q)
    language = Keyword.get(opts, :language)
    translator = Keyword.get(opts, :translator)
    surah = Keyword.get(opts, :surah)
    topic = Keyword.get(opts, :topic)
    revelation = Keyword.get(opts, :revelation)
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    offset = (page - 1) * per_page

    base_query =
      if language do
        # Search in translations
        Translation
        |> join(:inner, [t], a in Ayah, on: t.ayah_id == a.id)
        |> join(:inner, [t, a], s in Surah, on: a.surah_id == s.id)
        |> where([t], ilike(t.text, ^"%#{query}%"))
        |> maybe_filter_translation_by_language(language)
        |> maybe_filter_translation_by_translator(translator)
        |> maybe_filter_by_surah_id(surah)
        |> maybe_filter_by_revelation(revelation)
        |> maybe_filter_search_by_topic(topic)
        |> select([t, a, s], %{
          ayah_id: a.id,
          surah_id: s.id,
          surah_name: s.name_en,
          chapter_number: s.chapter_number,
          ayah_number: a.ayah_number,
          arabic_text: a.arabic_text,
          translation: t.text,
          language_code: t.language_code,
          translator: t.translator
        })
      else
        # Search in Arabic text
        Ayah
        |> join(:inner, [a], s in Surah, on: a.surah_id == s.id)
        |> where([a], ilike(a.arabic_text, ^"%#{query}%"))
        |> maybe_filter_by_surah_id(surah)
        |> maybe_filter_by_revelation(revelation)
        |> maybe_filter_search_by_topic(topic)
        |> select([a, s], %{
          ayah_id: a.id,
          surah_id: s.id,
          surah_name: s.name_en,
          chapter_number: s.chapter_number,
          ayah_number: a.ayah_number,
          arabic_text: a.arabic_text
        })
      end

    total = Repo.aggregate(base_query, :count, :ayah_id, distinct: true)

    results =
      base_query
      |> limit(^per_page)
      |> offset(^offset)
      |> Repo.all()

    %{
      results: results,
      total: total,
      page: page,
      per_page: per_page,
      total_pages: ceil(total / per_page)
    }
  end

  defp maybe_filter_translation_by_language(query, nil), do: query

  defp maybe_filter_translation_by_language(query, lang),
    do: where(query, [t], t.language_code == ^lang)

  defp maybe_filter_translation_by_translator(query, nil), do: query

  defp maybe_filter_translation_by_translator(query, translator),
    do: where(query, [t], t.translator == ^translator)

  defp maybe_filter_by_surah_id(query, nil), do: query

  defp maybe_filter_by_surah_id(query, surah_id),
    do: where(query, [_, a], a.surah_id == ^surah_id)

  defp maybe_filter_by_revelation(query, nil), do: query

  defp maybe_filter_by_revelation(query, revelation),
    do: where(query, [_, _, s], s.revelation_type == ^revelation)

  defp maybe_filter_search_by_topic(query, nil), do: query

  defp maybe_filter_search_by_topic(query, topic_slug) do
    query
    |> join(:inner, [..., a], at in AyahTopic, on: at.ayah_id == a.id)
    |> join(:inner, [..., at], t in Topic, on: t.id == at.topic_id)
    |> where([..., t], t.slug == ^topic_slug)
  end

  # ==================== Featured Ayahs ====================

  @doc """
  Returns famous/featured ayahs including:
  - Ayatul Kursi (2:255)
  - Last two verses of Al-Baqarah (2:285-286)
  - Surah Al-Ikhlas (112:1-4)
  - Surah Al-Falaq (113:1-5)
  - Surah An-Nas (114:1-6)
  """
  @spec get_featured_ayahs(keyword()) :: [Ayah.t()]
  def get_featured_ayahs(opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    featured_references = [
      {2, 255},
      {2, 285},
      {2, 286},
      {112, 1},
      {112, 2},
      {112, 3},
      {112, 4},
      {113, 1},
      {113, 2},
      {113, 3},
      {113, 4},
      {113, 5},
      {114, 1},
      {114, 2},
      {114, 3},
      {114, 4},
      {114, 5},
      {114, 6}
    ]

    Enum.flat_map(featured_references, fn {surah_num, ayah_num} ->
      case get_surah_by_number(surah_num) do
        nil ->
          []

        surah ->
          case get_ayah_by_surah_and_number(surah.id, ayah_num, preload: preload) do
            nil -> []
            ayah -> [ayah]
          end
      end
    end)
  end

  # ==================== Metadata & Stats ====================

  @doc """
  Returns statistics about the Quran database.
  """
  @spec get_stats() :: map()
  def get_stats do
    %{
      total_surahs: Repo.aggregate(Surah, :count, :id),
      total_ayahs: Repo.aggregate(Ayah, :count, :id),
      total_translations: Repo.aggregate(Translation, :count, :id),
      total_tafsirs: Repo.aggregate(Tafsir, :count, :id),
      total_audio: Repo.aggregate(Audio, :count, :id),
      total_topics: Repo.aggregate(Topic, :count, :id),
      languages: length(list_languages()),
      translators: length(list_translators()),
      reciters: length(list_reciters()),
      tafsir_authors: length(list_tafsir_authors())
    }
  end

  @doc """
  Returns metadata about the API.
  """
  @spec get_metadata() :: map()
  def get_metadata do
    %{
      api_version: "1.0.0",
      total_surahs: 114,
      total_ayahs: 6236,
      available_languages: list_languages(),
      available_translators: list_translators(),
      available_reciters: list_reciters(),
      available_tafsir_authors: list_tafsir_authors(),
      supported_features: [
        "random_verse",
        "daily_verse",
        "search",
        "translations",
        "tafsir",
        "audio",
        "topics",
        "batch_retrieval"
      ]
    }
  end
end
