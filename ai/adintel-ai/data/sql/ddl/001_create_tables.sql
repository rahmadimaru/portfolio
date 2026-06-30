-- ============================================================================
-- AdIntel AI
-- Milestone 2: PostgreSQL Database & SQL Mart Layer
-- File: sql/ddl/001_create_tables.sql
--
-- Purpose:
-- - Create PostgreSQL schemas for raw, marts, and metadata layers
-- - Create raw tables aligned with synthetic CSV outputs
-- - Add practical keys and indexes for local dashboard/RCA development
--
-- Source:
-- - data/synthetic/*.csv
--
-- Notes:
-- - This DDL is intentionally local-development friendly.
-- - DROP TABLE is used so the database can be rebuilt repeatedly.
-- - Core dimension foreign keys are enforced.
-- - Fact table foreign keys are mostly not enforced to avoid fragile local loads.
--   Missing FK checks should be handled in sql/analysis/validation_checks.sql.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS marts;
CREATE SCHEMA IF NOT EXISTS metadata;

-- ============================================================================
-- Local development reset
-- Drop fact tables first, then dimensions.
-- ============================================================================

DROP TABLE IF EXISTS raw.data_quality_logs CASCADE;
DROP TABLE IF EXISTS raw.billing_revenue CASCADE;
DROP TABLE IF EXISTS raw.conversion_events CASCADE;
DROP TABLE IF EXISTS raw.video_performance CASCADE;
DROP TABLE IF EXISTS raw.daily_ad_performance CASCADE;
DROP TABLE IF EXISTS raw.inventory CASCADE;

DROP TABLE IF EXISTS raw.devices CASCADE;
DROP TABLE IF EXISTS raw.markets CASCADE;
DROP TABLE IF EXISTS raw.placements CASCADE;
DROP TABLE IF EXISTS raw.creatives CASCADE;
DROP TABLE IF EXISTS raw.ad_groups CASCADE;
DROP TABLE IF EXISTS raw.campaigns CASCADE;
DROP TABLE IF EXISTS raw.advertisers CASCADE;

DROP TABLE IF EXISTS metadata.load_audit CASCADE;

-- ============================================================================
-- Dimension tables
-- ============================================================================

CREATE TABLE raw.advertisers (
    advertiser_id TEXT PRIMARY KEY,
    advertiser_name TEXT NOT NULL,
    industry TEXT NOT NULL,
    advertiser_tier TEXT NOT NULL,
    country_origin TEXT NOT NULL,
    is_strategic_account BOOLEAN NOT NULL,
    created_at DATE NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raw.campaigns (
    campaign_id TEXT PRIMARY KEY,
    advertiser_id TEXT NOT NULL,
    campaign_name TEXT NOT NULL,
    objective TEXT NOT NULL,
    buying_type TEXT NOT NULL,
    campaign_status TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_budget_usd NUMERIC(18,4) NOT NULL,
    daily_budget_usd NUMERIC(18,4) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_campaigns_advertiser
        FOREIGN KEY (advertiser_id)
        REFERENCES raw.advertisers (advertiser_id),

    CONSTRAINT chk_campaigns_budget_non_negative
        CHECK (total_budget_usd >= 0 AND daily_budget_usd >= 0),

    CONSTRAINT chk_campaigns_date_range
        CHECK (end_date >= start_date)
);

CREATE TABLE raw.ad_groups (
    ad_group_id TEXT PRIMARY KEY,
    campaign_id TEXT NOT NULL,
    ad_group_name TEXT NOT NULL,
    targeting_type TEXT NOT NULL,
    optimization_goal TEXT NOT NULL,
    bid_strategy TEXT NOT NULL,
    bid_amount_usd NUMERIC(18,4) NOT NULL,
    audience_size BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ad_groups_campaign
        FOREIGN KEY (campaign_id)
        REFERENCES raw.campaigns (campaign_id),

    CONSTRAINT chk_ad_groups_bid_non_negative
        CHECK (bid_amount_usd >= 0),

    CONSTRAINT chk_ad_groups_audience_non_negative
        CHECK (audience_size >= 0),

    CONSTRAINT chk_ad_groups_date_range
        CHECK (end_date >= start_date)
);

CREATE TABLE raw.creatives (
    creative_id TEXT PRIMARY KEY,
    advertiser_id TEXT NOT NULL,
    creative_name TEXT NOT NULL,
    creative_format TEXT NOT NULL,
    video_duration_sec NUMERIC(10,2),
    aspect_ratio TEXT NOT NULL,
    creative_quality_score NUMERIC(10,4) NOT NULL,
    is_video BOOLEAN NOT NULL,
    created_at DATE NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_creatives_advertiser
        FOREIGN KEY (advertiser_id)
        REFERENCES raw.advertisers (advertiser_id),

    CONSTRAINT chk_creatives_video_duration_non_negative
        CHECK (video_duration_sec IS NULL OR video_duration_sec >= 0),

    CONSTRAINT chk_creatives_quality_score_range
        CHECK (creative_quality_score >= 0 AND creative_quality_score <= 100)
);

CREATE TABLE raw.placements (
    placement_id TEXT PRIMARY KEY,
    placement_name TEXT NOT NULL,
    page_type TEXT NOT NULL,
    placement_position TEXT NOT NULL,
    inventory_type TEXT NOT NULL,
    ad_format_supported TEXT NOT NULL,
    baseline_viewability_rate NUMERIC(10,6) NOT NULL,
    baseline_ctr NUMERIC(10,6) NOT NULL,
    quality_tier TEXT NOT NULL,
    is_below_the_fold BOOLEAN NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_placements_baseline_viewability_range
        CHECK (baseline_viewability_rate >= 0 AND baseline_viewability_rate <= 1),

    CONSTRAINT chk_placements_baseline_ctr_range
        CHECK (baseline_ctr >= 0 AND baseline_ctr <= 1)
);

CREATE TABLE raw.markets (
    market_id TEXT PRIMARY KEY,
    market_name TEXT NOT NULL,
    region TEXT NOT NULL,
    currency TEXT NOT NULL,
    timezone TEXT NOT NULL,
    market_maturity TEXT NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raw.devices (
    device_id TEXT PRIMARY KEY,
    device_type TEXT NOT NULL,
    platform TEXT NOT NULL,
    os_family TEXT NOT NULL,
    is_app BOOLEAN NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- Fact table: daily ad performance
--
-- Grain:
-- - performance_id
--
-- Business usage:
-- - Core delivery, revenue, spend, CTR, CPM, eCPM, and viewability analysis
-- ============================================================================

CREATE TABLE raw.daily_ad_performance (
    performance_id TEXT PRIMARY KEY,
    date DATE NOT NULL,
    advertiser_id TEXT NOT NULL,
    campaign_id TEXT NOT NULL,
    ad_group_id TEXT NOT NULL,
    creative_id TEXT NOT NULL,
    placement_id TEXT NOT NULL,
    market_id TEXT NOT NULL,
    device_id TEXT NOT NULL,

    impressions BIGINT NOT NULL DEFAULT 0,
    clicks BIGINT NOT NULL DEFAULT 0,
    spend_usd NUMERIC(18,4) NOT NULL DEFAULT 0,
    publisher_revenue_usd NUMERIC(18,4) NOT NULL DEFAULT 0,
    measurable_impressions BIGINT NOT NULL DEFAULT 0,
    viewable_impressions BIGINT NOT NULL DEFAULT 0,
    viewability_rate NUMERIC(10,6) NOT NULL DEFAULT 0,
    served_cost_model TEXT NOT NULL,

    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_daily_ads_advertiser
        FOREIGN KEY (advertiser_id)
        REFERENCES raw.advertisers (advertiser_id),

    CONSTRAINT fk_daily_ads_campaign
        FOREIGN KEY (campaign_id)
        REFERENCES raw.campaigns (campaign_id),

    CONSTRAINT fk_daily_ads_ad_group
        FOREIGN KEY (ad_group_id)
        REFERENCES raw.ad_groups (ad_group_id),

    CONSTRAINT fk_daily_ads_creative
        FOREIGN KEY (creative_id)
        REFERENCES raw.creatives (creative_id),

    CONSTRAINT fk_daily_ads_placement
        FOREIGN KEY (placement_id)
        REFERENCES raw.placements (placement_id),

    CONSTRAINT fk_daily_ads_market
        FOREIGN KEY (market_id)
        REFERENCES raw.markets (market_id),

    CONSTRAINT fk_daily_ads_device
        FOREIGN KEY (device_id)
        REFERENCES raw.devices (device_id),

    CONSTRAINT chk_daily_ads_non_negative_metrics
        CHECK (
            impressions >= 0
            AND clicks >= 0
            AND spend_usd >= 0
            AND publisher_revenue_usd >= 0
            AND measurable_impressions >= 0
            AND viewable_impressions >= 0
        ),

    CONSTRAINT chk_daily_ads_clicks_not_above_impressions
        CHECK (clicks <= impressions),

    CONSTRAINT chk_daily_ads_viewable_not_above_measurable
        CHECK (viewable_impressions <= measurable_impressions),

    CONSTRAINT chk_daily_ads_viewability_rate_range
        CHECK (viewability_rate >= 0 AND viewability_rate <= 1)
);

-- ============================================================================
-- Fact table: inventory
--
-- Grain:
-- - inventory_id
--
-- Natural analytical grain:
-- - date + placement_id + market_id + device_id
--
-- Business usage:
-- - Fill rate, win rate, inventory quality, supply-side diagnostics
-- ============================================================================

CREATE TABLE raw.inventory (
    inventory_id TEXT PRIMARY KEY,
    date DATE NOT NULL,
    placement_id TEXT NOT NULL,
    market_id TEXT NOT NULL,
    device_id TEXT NOT NULL,

    ad_requests BIGINT NOT NULL DEFAULT 0,
    eligible_requests BIGINT NOT NULL DEFAULT 0,
    bid_requests BIGINT NOT NULL DEFAULT 0,
    bid_responses BIGINT NOT NULL DEFAULT 0,
    won_impressions BIGINT NOT NULL DEFAULT 0,
    fill_rate NUMERIC(10,6) NOT NULL DEFAULT 0,
    win_rate NUMERIC(10,6) NOT NULL DEFAULT 0,
    inventory_quality_score NUMERIC(10,4) NOT NULL DEFAULT 0,

    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_placement
        FOREIGN KEY (placement_id)
        REFERENCES raw.placements (placement_id),

    CONSTRAINT fk_inventory_market
        FOREIGN KEY (market_id)
        REFERENCES raw.markets (market_id),

    CONSTRAINT fk_inventory_device
        FOREIGN KEY (device_id)
        REFERENCES raw.devices (device_id),

    CONSTRAINT uq_inventory_business_grain
        UNIQUE (date, placement_id, market_id, device_id),

    CONSTRAINT chk_inventory_non_negative_metrics
        CHECK (
            ad_requests >= 0
            AND eligible_requests >= 0
            AND bid_requests >= 0
            AND bid_responses >= 0
            AND won_impressions >= 0
        ),

    CONSTRAINT chk_inventory_fill_rate_range
        CHECK (fill_rate >= 0 AND fill_rate <= 1),

    CONSTRAINT chk_inventory_win_rate_range
        CHECK (win_rate >= 0 AND win_rate <= 1),

    CONSTRAINT chk_inventory_quality_score_range
        CHECK (inventory_quality_score >= 0 AND inventory_quality_score <= 100)
);

-- ============================================================================
-- Fact table: video performance
--
-- Grain:
-- - video_performance_id
--
-- Business usage:
-- - Video funnel and VCR analysis
-- ============================================================================

CREATE TABLE raw.video_performance (
    video_performance_id TEXT PRIMARY KEY,
    performance_id TEXT NOT NULL,
    date DATE NOT NULL,
    creative_id TEXT NOT NULL,

    video_starts BIGINT NOT NULL DEFAULT 0,
    video_25p BIGINT NOT NULL DEFAULT 0,
    video_50p BIGINT NOT NULL DEFAULT 0,
    video_75p BIGINT NOT NULL DEFAULT 0,
    video_completes BIGINT NOT NULL DEFAULT 0,
    video_completion_rate NUMERIC(10,6) NOT NULL DEFAULT 0,

    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_video_performance_daily_ads
        FOREIGN KEY (performance_id)
        REFERENCES raw.daily_ad_performance (performance_id),

    CONSTRAINT fk_video_performance_creative
        FOREIGN KEY (creative_id)
        REFERENCES raw.creatives (creative_id),

    CONSTRAINT chk_video_performance_non_negative_metrics
        CHECK (
            video_starts >= 0
            AND video_25p >= 0
            AND video_50p >= 0
            AND video_75p >= 0
            AND video_completes >= 0
        ),

    CONSTRAINT chk_video_completion_rate_range
        CHECK (video_completion_rate >= 0 AND video_completion_rate <= 1),

    CONSTRAINT chk_video_funnel_order
        CHECK (
            video_completes <= video_75p
            AND video_75p <= video_50p
            AND video_50p <= video_25p
            AND video_25p <= video_starts
        )
);

-- ============================================================================
-- Fact table: conversion events
--
-- Grain:
-- - conversion_event_id
--
-- Business usage:
-- - Conversion, CVR, CPA, ROAS analysis
-- ============================================================================

CREATE TABLE raw.conversion_events (
    conversion_event_id TEXT PRIMARY KEY,
    performance_id TEXT NOT NULL,
    date DATE NOT NULL,
    conversion_type TEXT NOT NULL,
    conversions BIGINT NOT NULL DEFAULT 0,
    conversion_value_usd NUMERIC(18,4) NOT NULL DEFAULT 0,
    attribution_window_day INTEGER NOT NULL,

    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_conversion_events_daily_ads
        FOREIGN KEY (performance_id)
        REFERENCES raw.daily_ad_performance (performance_id),

    CONSTRAINT chk_conversion_events_non_negative_metrics
        CHECK (
            conversions >= 0
            AND conversion_value_usd >= 0
            AND attribution_window_day >= 0
        )
);

-- ============================================================================
-- Fact table: billing revenue
--
-- Grain:
-- - billing_id
--
-- Business usage:
-- - Revenue reconciliation against raw.daily_ad_performance publisher revenue
-- ============================================================================

CREATE TABLE raw.billing_revenue (
    billing_id TEXT PRIMARY KEY,
    date DATE NOT NULL,
    advertiser_id TEXT NOT NULL,
    campaign_id TEXT NOT NULL,
    market_id TEXT NOT NULL,

    billable_impressions BIGINT NOT NULL DEFAULT 0,
    billable_clicks BIGINT NOT NULL DEFAULT 0,
    gross_revenue_usd NUMERIC(18,4) NOT NULL DEFAULT 0,
    discount_usd NUMERIC(18,4) NOT NULL DEFAULT 0,
    net_revenue_usd NUMERIC(18,4) NOT NULL DEFAULT 0,
    billing_status TEXT NOT NULL,

    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_billing_revenue_advertiser
        FOREIGN KEY (advertiser_id)
        REFERENCES raw.advertisers (advertiser_id),

    CONSTRAINT fk_billing_revenue_campaign
        FOREIGN KEY (campaign_id)
        REFERENCES raw.campaigns (campaign_id),

    CONSTRAINT fk_billing_revenue_market
        FOREIGN KEY (market_id)
        REFERENCES raw.markets (market_id),

    CONSTRAINT chk_billing_revenue_non_negative_metrics
        CHECK (
            billable_impressions >= 0
            AND billable_clicks >= 0
            AND gross_revenue_usd >= 0
            AND discount_usd >= 0
            AND net_revenue_usd >= 0
        ),

    CONSTRAINT chk_billing_revenue_discount_not_above_gross
        CHECK (discount_usd <= gross_revenue_usd)
);

-- ============================================================================
-- Data quality logs
--
-- Grain:
-- - dq_log_id
--
-- Business usage:
-- - Tracking/data quality impact analysis
-- ============================================================================

CREATE TABLE raw.data_quality_logs (
    dq_log_id TEXT PRIMARY KEY,
    date DATE NOT NULL,
    issue_type TEXT NOT NULL,
    severity TEXT NOT NULL,
    affected_table TEXT NOT NULL,
    market_id TEXT NOT NULL,
    device_id TEXT NOT NULL,
    placement_id TEXT NOT NULL,
    estimated_affected_rows BIGINT NOT NULL DEFAULT 0,
    description TEXT NOT NULL,
    is_root_cause_candidate BOOLEAN NOT NULL,

    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_dq_logs_market
        FOREIGN KEY (market_id)
        REFERENCES raw.markets (market_id),

    CONSTRAINT fk_dq_logs_device
        FOREIGN KEY (device_id)
        REFERENCES raw.devices (device_id),

    CONSTRAINT fk_dq_logs_placement
        FOREIGN KEY (placement_id)
        REFERENCES raw.placements (placement_id),

    CONSTRAINT chk_dq_logs_estimated_rows_non_negative
        CHECK (estimated_affected_rows >= 0)
);

-- ============================================================================
-- Metadata tables
-- ============================================================================

CREATE TABLE metadata.load_audit (
    load_audit_id BIGSERIAL PRIMARY KEY,
    table_schema TEXT NOT NULL,
    table_name TEXT NOT NULL,
    source_file_name TEXT,
    loaded_row_count BIGINT,
    load_status TEXT NOT NULL,
    error_message TEXT,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- Indexes: dimensions
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_advertisers_industry
ON raw.advertisers (industry);

CREATE INDEX IF NOT EXISTS idx_advertisers_tier
ON raw.advertisers (advertiser_tier);

CREATE INDEX IF NOT EXISTS idx_campaigns_advertiser_id
ON raw.campaigns (advertiser_id);

CREATE INDEX IF NOT EXISTS idx_campaigns_status
ON raw.campaigns (campaign_status);

CREATE INDEX IF NOT EXISTS idx_campaigns_objective
ON raw.campaigns (objective);

CREATE INDEX IF NOT EXISTS idx_campaigns_date_range
ON raw.campaigns (start_date, end_date);

CREATE INDEX IF NOT EXISTS idx_ad_groups_campaign_id
ON raw.ad_groups (campaign_id);

CREATE INDEX IF NOT EXISTS idx_ad_groups_targeting_type
ON raw.ad_groups (targeting_type);

CREATE INDEX IF NOT EXISTS idx_ad_groups_optimization_goal
ON raw.ad_groups (optimization_goal);

CREATE INDEX IF NOT EXISTS idx_creatives_advertiser_id
ON raw.creatives (advertiser_id);

CREATE INDEX IF NOT EXISTS idx_creatives_format
ON raw.creatives (creative_format);

CREATE INDEX IF NOT EXISTS idx_creatives_is_video
ON raw.creatives (is_video);

CREATE INDEX IF NOT EXISTS idx_placements_inventory_type
ON raw.placements (inventory_type);

CREATE INDEX IF NOT EXISTS idx_placements_quality_tier
ON raw.placements (quality_tier);

CREATE INDEX IF NOT EXISTS idx_placements_position
ON raw.placements (placement_position);

CREATE INDEX IF NOT EXISTS idx_markets_region
ON raw.markets (region);

CREATE INDEX IF NOT EXISTS idx_markets_maturity
ON raw.markets (market_maturity);

CREATE INDEX IF NOT EXISTS idx_devices_platform
ON raw.devices (platform);

CREATE INDEX IF NOT EXISTS idx_devices_is_app
ON raw.devices (is_app);

-- ============================================================================
-- Indexes: daily ad performance
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_daily_ads_date
ON raw.daily_ad_performance (date);

CREATE INDEX IF NOT EXISTS idx_daily_ads_advertiser_id
ON raw.daily_ad_performance (advertiser_id);

CREATE INDEX IF NOT EXISTS idx_daily_ads_campaign_id
ON raw.daily_ad_performance (campaign_id);

CREATE INDEX IF NOT EXISTS idx_daily_ads_ad_group_id
ON raw.daily_ad_performance (ad_group_id);

CREATE INDEX IF NOT EXISTS idx_daily_ads_creative_id
ON raw.daily_ad_performance (creative_id);

CREATE INDEX IF NOT EXISTS idx_daily_ads_placement_id
ON raw.daily_ad_performance (placement_id);

CREATE INDEX IF NOT EXISTS idx_daily_ads_device_id
ON raw.daily_ad_performance (device_id);

CREATE INDEX IF NOT EXISTS idx_daily_ads_market_id
ON raw.daily_ad_performance (market_id);

CREATE INDEX IF NOT EXISTS idx_daily_ads_cost_model
ON raw.daily_ad_performance (served_cost_model);

CREATE INDEX IF NOT EXISTS idx_daily_ads_date_campaign
ON raw.daily_ad_performance (date, campaign_id);

CREATE INDEX IF NOT EXISTS idx_daily_ads_date_advertiser
ON raw.daily_ad_performance (date, advertiser_id);

CREATE INDEX IF NOT EXISTS idx_daily_ads_date_placement
ON raw.daily_ad_performance (date, placement_id);

CREATE INDEX IF NOT EXISTS idx_daily_ads_date_device
ON raw.daily_ad_performance (date, device_id);

CREATE INDEX IF NOT EXISTS idx_daily_ads_date_market
ON raw.daily_ad_performance (date, market_id);

CREATE INDEX IF NOT EXISTS idx_daily_ads_date_creative
ON raw.daily_ad_performance (date, creative_id);

-- ============================================================================
-- Indexes: inventory
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_inventory_date
ON raw.inventory (date);

CREATE INDEX IF NOT EXISTS idx_inventory_placement_id
ON raw.inventory (placement_id);

CREATE INDEX IF NOT EXISTS idx_inventory_market_id
ON raw.inventory (market_id);

CREATE INDEX IF NOT EXISTS idx_inventory_device_id
ON raw.inventory (device_id);

CREATE INDEX IF NOT EXISTS idx_inventory_date_placement
ON raw.inventory (date, placement_id);

CREATE INDEX IF NOT EXISTS idx_inventory_date_market
ON raw.inventory (date, market_id);

CREATE INDEX IF NOT EXISTS idx_inventory_date_device
ON raw.inventory (date, device_id);

CREATE INDEX IF NOT EXISTS idx_inventory_date_placement_market_device
ON raw.inventory (date, placement_id, market_id, device_id);

-- ============================================================================
-- Indexes: video performance
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_video_performance_performance_id
ON raw.video_performance (performance_id);

CREATE INDEX IF NOT EXISTS idx_video_performance_date
ON raw.video_performance (date);

CREATE INDEX IF NOT EXISTS idx_video_performance_creative_id
ON raw.video_performance (creative_id);

CREATE INDEX IF NOT EXISTS idx_video_performance_date_creative
ON raw.video_performance (date, creative_id);

-- ============================================================================
-- Indexes: conversion events
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_conversion_events_performance_id
ON raw.conversion_events (performance_id);

CREATE INDEX IF NOT EXISTS idx_conversion_events_date
ON raw.conversion_events (date);

CREATE INDEX IF NOT EXISTS idx_conversion_events_type
ON raw.conversion_events (conversion_type);

CREATE INDEX IF NOT EXISTS idx_conversion_events_date_type
ON raw.conversion_events (date, conversion_type);

-- ============================================================================
-- Indexes: billing revenue
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_billing_revenue_date
ON raw.billing_revenue (date);

CREATE INDEX IF NOT EXISTS idx_billing_revenue_advertiser_id
ON raw.billing_revenue (advertiser_id);

CREATE INDEX IF NOT EXISTS idx_billing_revenue_campaign_id
ON raw.billing_revenue (campaign_id);

CREATE INDEX IF NOT EXISTS idx_billing_revenue_market_id
ON raw.billing_revenue (market_id);

CREATE INDEX IF NOT EXISTS idx_billing_revenue_status
ON raw.billing_revenue (billing_status);

CREATE INDEX IF NOT EXISTS idx_billing_revenue_date_campaign_market
ON raw.billing_revenue (date, campaign_id, market_id);

-- ============================================================================
-- Indexes: data quality logs
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_data_quality_logs_date
ON raw.data_quality_logs (date);

CREATE INDEX IF NOT EXISTS idx_data_quality_logs_issue_type
ON raw.data_quality_logs (issue_type);

CREATE INDEX IF NOT EXISTS idx_data_quality_logs_severity
ON raw.data_quality_logs (severity);

CREATE INDEX IF NOT EXISTS idx_data_quality_logs_affected_table
ON raw.data_quality_logs (affected_table);

CREATE INDEX IF NOT EXISTS idx_data_quality_logs_root_cause_candidate
ON raw.data_quality_logs (is_root_cause_candidate);

CREATE INDEX IF NOT EXISTS idx_data_quality_logs_date_market_device_placement
ON raw.data_quality_logs (date, market_id, device_id, placement_id);

