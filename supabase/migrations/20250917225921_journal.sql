--
-- Schemas
--
CREATE SCHEMA IF NOT EXISTS journal;

--
-- Enums
--
CREATE TYPE journal.writing_type AS ENUM (
  'Journaling',
  'Weekly Review',
  'Yearly Review',
  'Goals & Planning',
  'Brainstorming',
  'Creative',
  'Other'
);

--
-- Tables
--
CREATE TABLE journal.writings (
  id UUID PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT (now() AT TIME ZONE 'utc'),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT (now() AT TIME ZONE 'utc'),
  type journal.writing_type DEFAULT 'Other'::journal.writing_type,
  subject TEXT CHECK (char_length(subject) <= 100),
  content TEXT CHECK (char_length(content) <= 50000),
  search_vector tsvector GENERATED ALWAYS AS (
    setweight(to_tsvector('english', coalesce(subject, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(content, '')), 'B')
  ) STORED
);

--
-- Indexes
--
CREATE INDEX writings_search_idx ON journal.writings USING gin(search_vector);

--
-- RLS Policies
--
ALTER TABLE journal.writings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Select own writings" ON journal.writings
  FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Insert own writings" ON journal.writings
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Update own writings" ON journal.writings
  FOR UPDATE TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Delete own writings" ON journal.writings
  FOR DELETE TO authenticated
  USING ((SELECT auth.uid()) = user_id);

--
-- Functions
--
CREATE OR REPLACE FUNCTION updated_at()
RETURNS TRIGGER
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at = (now() AT TIME ZONE 'utc');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- GET WRITING
CREATE OR REPLACE FUNCTION journal.get_writing(i_writing_id UUID)
RETURNS TABLE(
  id UUID,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  type journal.writing_type,
  subject TEXT,
  content TEXT
)
SET search_path = ''
AS $$
BEGIN
  RETURN QUERY
  SELECT w.id,
         w.created_at,
         w.updated_at,
         w.type,
         w.subject,
         w.content
  FROM journal.writings w
  WHERE w.user_id = auth.uid() AND w.id = i_writing_id;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION journal.get_writing(UUID) TO authenticated;

-- SEARCH WRITINGS
CREATE OR REPLACE FUNCTION journal.search_writings(
  i_search_text TEXT DEFAULT NULL,
  i_type journal.writing_type DEFAULT NULL,
  i_start_date TIMESTAMPTZ DEFAULT NULL,
  i_end_date TIMESTAMPTZ DEFAULT NULL,
  i_offset INT DEFAULT 0
)
RETURNS TABLE(
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  type journal.writing_type,
  subject TEXT,
  content TEXT
)
SET search_path = ''
AS $$
BEGIN
  RETURN QUERY
  SELECT w.id,
         w.created_at,
         w.updated_at,
         w.type,
         w.subject,
         w.content
  FROM journal.writings w
  WHERE w.user_id = auth.uid()
    AND (i_search_text IS NULL OR w.search_vector @@ plainto_tsquery('english', i_search_text))
    AND (i_type IS NULL OR w.type = i_type)
    AND (i_start_date IS NULL OR w.created_at >= i_start_date)
    AND (i_end_date IS NULL OR w.created_at <= i_end_date)
  ORDER BY
    CASE WHEN s_search_text IS NOT NULL THEN ts_rank(w.search_vector, plainto_tsquery('english', s_search_text)) END DESC NULLS LAST,
    w.created_at DESC
  LIMIT 50 -- Limit results per page
  OFFSET s_offset;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION journal.search_writings(TEXT, journal.writing_type, TIMESTAMPTZ, TIMESTAMPTZ, INT) TO authenticated;

-- CREATE WRITING
CREATE OR REPLACE FUNCTION journal.create_writing(
  i_type journal.writing_type,
  i_subject TEXT,
  i_content TEXT
)
RETURNS TABLE(
  id UUID,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  type journal.writing_type,
  subject TEXT,
  content TEXT
)
SET search_path = ''
AS $$
BEGIN
  RETURN QUERY
  INSERT INTO journal.writings (user_id, type, subject, content)
  VALUES (auth.uid(), i_type, i_subject, i_content)
  RETURNING id, created_at, updated_at, type, subject, content;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION journal.create_writing(journal.writing_type, TEXT, TEXT) TO authenticated;

-- UPDATE WRITING
CREATE OR REPLACE FUNCTION journal.update_writing(
  i_writing_id UUID,
  i_type journal.writing_type,
  i_subject TEXT,
  i_content TEXT
)
RETURNS TABLE(
  id UUID,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  type journal.writing_type,
  subject TEXT,
  content TEXT
)
SET search_path = ''
AS $$
BEGIN
  RETURN QUERY
  UPDATE journal.writings
  SET type = i_type,
      subject = i_subject,
      content = i_content
  WHERE user_id = auth.uid() AND id = i_writing_id
  RETURNING id, created_at, updated_at, type, subject, content;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION journal.update_writing(UUID, journal.writing_type, TEXT, TEXT) TO authenticated;

-- DELETE WRITING
CREATE OR REPLACE FUNCTION journal.delete_writing(i_writing_id UUID)
RETURNS TABLE(
  id UUID,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  type journal.writing_type,
  subject TEXT,
  content TEXT
)
SET search_path = ''
AS $$
BEGIN
  RETURN QUERY
  DELETE FROM journal.writings
  WHERE user_id = auth.uid() AND id = i_writing_id
  RETURNING id, created_at, updated_at, type, subject, content;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION journal.delete_writing(UUID) TO authenticated;

-- EXPORT WRITINGS
CREATE OR REPLACE FUNCTION journal.export_writings_to_json(
  i_offset INT DEFAULT 0
)
RETURNS JSONB
SET search_path = ''
AS $$
DECLARE
  writings_json JSONB;
BEGIN
  SELECT jsonb_agg(jsonb_build_object(
    'created_at', created_at,
    'type', type,
    'subject', subject,
    'content', content
  )) INTO writings_json
  FROM journal.writings
  WHERE user_id = auth.uid()
  ORDER BY created_at DESC -- Most recent first
  LIMIT 10000 -- Max limit to protect database performance
  OFFSET i_offset;
  RETURN writings_json;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION journal.export_writings_to_json(INT) TO authenticated;

--
-- Triggers
--
CREATE TRIGGER trigger_updated_at_writings
BEFORE UPDATE ON journal.writings
FOR EACH ROW
EXECUTE FUNCTION updated_at();

--
-- Final (have to rerun if you add new tables)
--
REVOKE ALL ON ALL TABLES IN SCHEMA journal FROM anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA journal FROM anon, authenticated;
