-- AI FOR FEEDBACK: proposed schema (validate against the chosen dataset)

CREATE TABLE IF NOT EXISTS processing_runs (
    run_id          TEXT PRIMARY KEY,
    started_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    finished_at     TIMESTAMPTZ,
    status          TEXT NOT NULL DEFAULT 'running'
                    CHECK (status IN ('running','success','failed')),
    rows_received   INT DEFAULT 0,
    rows_invalid    INT DEFAULT 0,
    rows_duplicate  INT DEFAULT 0,
    rows_enriched   INT DEFAULT 0,
    rows_failed     INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS raw_feedback (
    id               BIGSERIAL PRIMARY KEY,
    source_review_id TEXT UNIQUE,
    product          TEXT,
    category         TEXT,
    original_text    TEXT,
    review_date_raw  TEXT,
    run_id           TEXT REFERENCES processing_runs(run_id),
    ingested_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS enriched_feedback (
    source_review_id  TEXT PRIMARY KEY,
    product           TEXT,
    category          TEXT,
    review_date       DATE,
    original_text     TEXT NOT NULL,
    cleaned_text      TEXT NOT NULL,
    sentiment         TEXT NOT NULL
                      CHECK (sentiment IN ('POSITIVE','NEUTRAL','NEGATIVE')),
    sentiment_score   NUMERIC,
    model_id          TEXT NOT NULL,
    processed_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    processing_status TEXT NOT NULL DEFAULT 'success'
                      CHECK (processing_status IN ('success','failed')),
    run_id            TEXT REFERENCES processing_runs(run_id)
);

CREATE TABLE IF NOT EXISTS processing_errors (
    error_id         BIGSERIAL PRIMARY KEY,
    run_id           TEXT REFERENCES processing_runs(run_id),
    source_review_id TEXT,
    stage            TEXT NOT NULL
                     CHECK (stage IN ('ingestion','validation','inference','load')),
    reason           TEXT NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_enriched_product_date
    ON enriched_feedback (product, review_date);
CREATE INDEX IF NOT EXISTS idx_errors_run ON processing_errors (run_id);
