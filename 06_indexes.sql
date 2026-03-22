-- ============================================================
-- Author:      Riaan Meintjes
-- Date:        2026-03-22
-- Module:      ITMDA0-11 Database Management (MySQL)
-- Project:     1 - Global Coding Bootcamp Platform
-- Purpose:     Create indexes for faster lookups and query
--              optimisation on commonly searched columns
-- ============================================================

USE global_bootcamp;

-- ============================================================
-- INDEXES ON: learners
-- Reason: username and email are frequently used in logins,
--         registrations, and lookups.
--         subscription_expiry is used by triggers and views
--         to identify expired/blocked accounts.
-- ============================================================
CREATE INDEX idx_learners_username
    ON learners (username);

CREATE INDEX idx_learners_email
    ON learners (email);

CREATE INDEX idx_learners_status_expiry
    ON learners (account_status, subscription_expiry);

-- ============================================================
-- INDEXES ON: bootcamps
-- Reason: category and level are commonly used in filter
--         queries; mentor_id is a foreign key used in JOINs.
-- ============================================================
CREATE INDEX idx_bootcamps_category
    ON bootcamps (category);

CREATE INDEX idx_bootcamps_level
    ON bootcamps (level);

CREATE INDEX idx_bootcamps_mentor
    ON bootcamps (mentor_id);

-- ============================================================
-- INDEXES ON: enrollments
-- Reason: Queries often look up all bootcamps for a learner
--         or all learners in a bootcamp. Both FK columns
--         benefit from their own indexes.
-- ============================================================
CREATE INDEX idx_enrollments_learner
    ON enrollments (learner_id);

CREATE INDEX idx_enrollments_bootcamp
    ON enrollments (bootcamp_id);

-- ============================================================
-- INDEXES ON: assessment_results
-- Reason: Skill score aggregation (used in vwTopCoders) and
--         lookups by learner or assessment are frequent.
-- ============================================================
CREATE INDEX idx_results_learner
    ON assessment_results (learner_id);

CREATE INDEX idx_results_assessment
    ON assessment_results (assessment_id);

CREATE INDEX idx_results_skill_score
    ON assessment_results (skill_score DESC);

-- ============================================================
-- INDEXES ON: resources
-- Reason: download_count is used for ranking in the
--         vwMostDownloadedResources view; resource_type is
--         used in filter queries.
-- ============================================================
CREATE INDEX idx_resources_bootcamp
    ON resources (bootcamp_id);

CREATE INDEX idx_resources_downloads
    ON resources (download_count DESC);

CREATE INDEX idx_resources_type
    ON resources (resource_type);

-- ============================================================
-- INDEXES ON: module_progress
-- Reason: Progress lookups are done by learner and by module.
-- ============================================================
CREATE INDEX idx_progress_learner
    ON module_progress (learner_id);

CREATE INDEX idx_progress_module
    ON module_progress (module_id);

-- ============================================================
-- INDEXES ON: error_log
-- Reason: Logs are commonly queried by category or learner
--         for reporting and debugging.
-- ============================================================
CREATE INDEX idx_errorlog_learner
    ON error_log (learner_id);

CREATE INDEX idx_errorlog_category
    ON error_log (error_category);

CREATE INDEX idx_errorlog_timestamp
    ON error_log (logged_at DESC);
