# AI FOR FEEDBACK

**AI-Enhanced Customer Feedback Data Pipeline**

DEPI (Digital Egypt Pioneers Initiative) · Microsoft Data Engineer Track · Graduation Project 07

A scheduled, AI-powered ETL pipeline that turns unstructured customer reviews into traceable sentiment records, SQL-ready summaries, and an analytics dashboard.

> **Status:** Planning phase (Oct 2026). Implementation is added milestone by milestone (M1 → M6). Tools, dataset, and performance targets are proposals until confirmed by the team and instructor.

---

## Table of Contents

- [Problem](#problem)
- [Solution](#solution)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Data Model](#data-model)
- [Data Quality Rules](#data-quality-rules)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Roadmap](#roadmap)
- [Success Criteria](#success-criteria)
- [Scope](#scope)
- [Team](#team)
- [Documentation](#documentation)

---

## Problem

Companies receive thousands of customer reviews and support comments as unstructured text. Reading them manually is slow, and raw feedback contains duplicates, missing values, inconsistent formatting, and entries that AI models may not process reliably. Analysts need a dependable pipeline that preserves the raw message, produces clear sentiment labels, and stores results in a structured database for repeatable analysis.

## Solution

```
CSV ingestion → Validation → Cleaning / Deduplication → Hugging Face sentiment inference
              → PostgreSQL storage → SQL / Pandas aggregation → Dashboard
```

All steps are orchestrated and monitored by **Apache Airflow**.

**Key outputs**

- Raw and enriched datasets, kept separately
- Per-record sentiment (Positive / Neutral / Negative) with score, model ID, and processing timestamp
- An error table for invalid rows and failed inference (never given a fabricated label)
- Aggregated views by product, category, date, and sentiment
- An analytics dashboard

**Optional extension (only after the mandatory scope is done):** LLM/LangChain extraction of structured fields (`product`, `issue_type`, `complaint`, `requested_action`) from free-form feedback.

## Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│     APACHE AIRFLOW · scheduling · retries · logging · quality gates │
└────────────────────────────────────────────────────────────────────┘
   01 INGEST      02 PREPARE        03 AI MODEL        04 STORE        05 ANALYZE
   CSV reviews →  Validate/clean →  Tokenize/classify → PostgreSQL  →  SQL + dashboard
   schema check   normalize/dedup   HF sentiment        raw/enriched    by product/date/
                                                        /runs           sentiment

   processing_errors : invalid rows & failed inference are logged
   processing_runs   : received / processed / rejected counts reconciled per batch
```

## Tech Stack

| Layer | Technology |
|---|---|
| Ingestion & cleaning | Python, Pandas |
| AI inference | Hugging Face Transformers |
| Storage | PostgreSQL + SQL |
| Orchestration | Apache Airflow |
| Reporting | Power BI or Matplotlib |
| Collaboration | Git / GitHub |

## Data Model

| Table | Role | Primary control |
|---|---|---|
| `raw_feedback` | Unmodified ingested reviews and source metadata | Preserve originals; track source IDs / batches |
| `enriched_feedback` | Cleaned text and AI sentiment results | Unique source keys, model ID, timestamp |
| `processing_runs` | Batch counts, duration, run status | Reconcile received / processed / rejected counts |
| `processing_errors` | Invalid records and model/database failures | Reason, source ID, run ID, no secrets |

**Proposed minimum schema**

| Field | Type / Example | Purpose |
|---|---|---|
| `source_review_id` | Text | Stable source identifier, unique when available |
| `product` | Text | Product-level summaries (optional) |
| `category` | Text | Source category (optional) |
| `original_text` | Text | Feedback preserved as received |
| `cleaned_text` | Text | Text after documented normalization |
| `sentiment` | Text (`POSITIVE`) | Predicted label |
| `sentiment_score` | Numeric | Model score as returned (not assumed to be a calibrated probability) |
| `model_id` | Text | Exact model identifier / version |
| `processed_at` | Timestamp | Processing time |
| `processing_status` | Text (`success` / `failed`) | Tracking and failure investigation |

The final schema will be validated against the selected dataset.

## Data Quality Rules

1. Reject or quarantine records with missing identifiers or empty text, and log the reason.
2. Preserve original text; normalize into a separate field without removing meaning-bearing negation or punctuation.
3. Define duplicate handling explicitly (stable source ID, or a documented field combination).
4. Use primary/unique constraints and idempotent upserts.
5. If inference fails, record the failure and retry per policy. Never silently assign a sentiment label.
6. Track rows received, invalid, duplicate, enriched, and failed so every batch can be reconciled.

## Project Structure

> Proposed layout; will be updated as modules are implemented.

```
.
├── dags/                 # Airflow DAG(s)
├── src/
│   ├── ingestion/        # CSV reader, schema validation
│   ├── preprocessing/    # Cleaning, normalization, deduplication
│   ├── inference/        # Hugging Face sentiment module
│   └── storage/          # PostgreSQL loaders, upserts
├── sql/                  # Schema, views, quality queries
├── dashboard/            # Dashboard files / notebooks
├── data/                 # Sample / permitted CSV (no sensitive data)
├── tests/                # Cleaning, dedup, and pipeline tests
├── docs/                 # Project documentation, diagrams
├── .env.example          # Environment variable template
├── requirements.txt
└── README.md
```

## Getting Started

> Detailed setup and run steps will be completed at milestone M5. The outline below is the target workflow.

**Prerequisites:** Python 3.x, PostgreSQL, Apache Airflow, and a machine able to run the selected Hugging Face model.

```bash
# 1. Clone
git clone https://github.com/sayedelakabawy/depi-final-project.git
cd depi-final-project

# 2. Create a virtual environment and install dependencies
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt

# 3. Configure environment (never commit real credentials)
cp .env.example .env

# 4. Initialize the database schema, then start Airflow and trigger the DAG
```

## Roadmap

| Period | Work package | Checkpoint |
|---|---|---|
| 19–31 Oct | Kickoff: dataset permissions, requirements, roles, repo, architecture, quality rules | **M0** Agreed scope, schema draft, backlog, sample data |
| 1–12 Nov | CSV ingestion, raw storage, schema checks, invalid/duplicate handling | **M1** Reproducible ingestion and cleaning tests |
| 13–24 Nov | Select a documented 3-class model, tokenize, benchmark, validate output | **M2** AI enrichment module + baseline evaluation |
| 25 Nov – 8 Dec | Enriched/error tables, idempotent loads, SQL summaries, integration | **M3** Queryable raw/enriched records, reconciliation |
| 9–17 Dec | Airflow DAG, retries, logs, quality gates, dashboard | **M4** Complete scheduled ETL run with dashboard evidence |
| 18–23 Dec | End-to-end tests, failure recovery, feature freeze, README, screenshots | **M5** Feature freeze + acceptance-test evidence |
| 24–30 Dec | Final review, rehearsal, packaging, sign-off, submission | **M6** Final repo, report, screenshots, demo |

Optional features are frozen by **17 December**. Final submission is planned for the last week of December 2026 (exact date to be confirmed).

## Success Criteria

| Measure | Target |
|---|---|
| Data integrity | 0 duplicate source IDs in curated data; original and cleaned text retained |
| Traceability | 100% of source rows reconciled as enriched, rejected, failed, or pending |
| AI output completeness | Every successful row has label, model ID, timestamp, and score |
| Model evaluation | Confusion matrix, accuracy, and macro-F1 on an agreed labeled sample |
| Pipeline reliability | 5 consecutive successful controlled end-to-end runs |
| Idempotent recovery | Re-running the same batch creates no extra curated records |
| Analytics readiness | Summaries/visuals by product, category, date, and sentiment |
| Reproducibility | Another teammate can run the sample workflow from this README |

## Scope

| In scope | Out of scope / future |
|---|---|
| Batch processing of permitted CSV reviews; validation, normalization, deduplication | Real-time chat monitoring and live streaming |
| Pre-trained 3-class sentiment classifier with evaluation | Training an LLM from scratch; guaranteed multilingual support |
| PostgreSQL raw / enriched / error datasets and SQL analyses | Enterprise-scale or cloud production deployment, high availability |
| Airflow scheduling, quality rules, error logging, dashboard, docs | Optional: LLM/LangChain extraction, ticket automation, agent responses |

## Team

| Member | Role |
|---|---|
| Omar Samir Abdelnabi Sharaf | Team Leader: project coordination and integration |
| Sayed Badawy Farouk Ahmed | Data ingestion and text preprocessing |
| Omar Mahmoud Ahmed Omar Abdelbaq | AI / NLP inference and evaluation |
| Youssef Mohammed Ezzat | Database architecture and data quality |
| Amr Yasser Elhabashy | Airflow orchestration and analytics dashboard |

## Documentation

Full project documentation (planning, literature review, requirements) is in `docs/AI_FOR_FEEDBACK_Project_Documentation.pdf`.

## Security & Privacy

- Credentials are never committed; use `.env` (see `.env.example`).
- Only public, permitted, or synthetic datasets are used; dataset and model licenses are checked before distribution.
- Personal data is redacted from logs and screenshots.

---

*Digital Egypt Pioneers Initiative (DEPI) · Data Engineering Graduation Project · October 2026*
