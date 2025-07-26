--
-- Views
--

CREATE VIEW public.todays_workouts AS
SELECT
  w.id,
  w.name,
  w.description,
  w.schedule,
  w.is_locked,
  wr.id AS last_id,
  wr.created_at AS last_created_at,
  wr.note AS last_note
FROM public.workouts w
LEFT JOIN LATERAL (
  SELECT
    wr.id,
    wr.created_at,
    wr.note
  FROM public.workout_results wr
  WHERE wr.workout_id = w.id
  ORDER BY wr.created_at DESC
  LIMIT 1
) wr ON TRUE
WHERE
  (
    -- Always show if 'Daily'
    'Daily' = ANY(w.schedule)
    OR
    -- Show if today matches a weekday in schedule
    TRIM(TO_CHAR(CURRENT_DATE, 'Day')) = ANY(w.schedule)
    OR
    -- Show if 'Weekly' and last result is before this week's
    (
      'Weekly' = ANY(w.schedule)
      AND (
        wr.created_at IS NULL
        OR wr.created_at::date < (CURRENT_DATE - INTERVAL '7 days')
      )
    )
  );
