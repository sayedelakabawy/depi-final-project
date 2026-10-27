-- Analytical views for the dashboard (FR-3.2, FR-3.3)

CREATE OR REPLACE VIEW v_sentiment_by_product_date AS
SELECT product,
       category,
       review_date,
       sentiment,
       COUNT(*)              AS review_count,
       AVG(sentiment_score)  AS avg_score
FROM enriched_feedback
WHERE processing_status = 'success'
GROUP BY product, category, review_date, sentiment;

CREATE OR REPLACE VIEW v_sentiment_summary AS
SELECT sentiment,
       COUNT(*) AS review_count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM enriched_feedback
WHERE processing_status = 'success'
GROUP BY sentiment;

-- Reconciliation per run: received = invalid + duplicate + enriched + failed
CREATE OR REPLACE VIEW v_run_reconciliation AS
SELECT run_id, status, rows_received,
       rows_invalid + rows_duplicate + rows_enriched + rows_failed AS rows_accounted,
       rows_received - (rows_invalid + rows_duplicate + rows_enriched + rows_failed) AS diff
FROM processing_runs;
