-- ============================================================
-- Author:      Riaan Meintjes
-- Date:        2026-03-22
-- Module:      ITMDA0-11 Database Management (MySQL)
-- Project:     1 - Global Coding Bootcamp Platform
-- Purpose:     Create all required views
-- ============================================================

USE global_bootcamp;

-- ============================================================
-- VIEW: vwBlockedLearners
-- Purpose: Shows learners whose subscriptions have expired
--          and whose accounts are currently blocked
-- ============================================================
CREATE OR REPLACE VIEW vwBlockedLearners AS
    SELECT
        l.learner_id,
        l.username,
        l.email,
        l.account_status,
        l.subscription_expiry,
        DATEDIFF(CURDATE(), l.subscription_expiry) AS days_overdue
    FROM
        learners l
    WHERE
        l.account_status = 'Blocked'
        AND l.subscription_expiry < CURDATE();

-- ============================================================
-- VIEW: vwTopCoders
-- Purpose: Ranks top 20 learners by their total skill score
--          accumulated across all assessment results.
-- Note:    Window functions inside VIEW subqueries cause errors
--          on some MySQL versions. Ranking is derived from the
--          ORDER BY on the aggregated total instead.
-- ============================================================
CREATE OR REPLACE VIEW vwTopCoders AS
    SELECT
        l.learner_id,
        l.username,
        l.email,
        SUM(ar.skill_score)  AS total_skill_score,
        COUNT(ar.result_id)  AS assessments_completed
    FROM
        learners l
        INNER JOIN assessment_results ar ON l.learner_id = ar.learner_id
    GROUP BY
        l.learner_id,
        l.username,
        l.email
    ORDER BY
        total_skill_score DESC
    LIMIT 20;

-- ============================================================
-- VIEW: vwMostDownloadedResources
-- Purpose: Shows the top 20 most downloaded resources across
--          all bootcamps, including the bootcamp they belong to.
-- Note:    RANK() window function removed for compatibility.
--          Resources are ordered by download_count descending.
-- ============================================================
CREATE OR REPLACE VIEW vwMostDownloadedResources AS
    SELECT
        r.resource_id,
        r.title        AS resource_title,
        r.resource_type,
        r.size_mb,
        r.download_count,
        b.title        AS bootcamp_title,
        b.category     AS bootcamp_category
    FROM
        resources r
        INNER JOIN bootcamps b ON r.bootcamp_id = b.bootcamp_id
    ORDER BY
        r.download_count DESC
    LIMIT 20;

-- ============================================================
-- VIEW: vwPopularBootcamps
-- Purpose: Shows the top 5 bootcamps ranked by total enrollment
--          count, including mentor and capacity information
-- ============================================================
CREATE OR REPLACE VIEW vwPopularBootcamps AS
    SELECT
        b.bootcamp_id,
        b.title                                              AS bootcamp_title,
        b.category,
        b.level,
        b.capacity,
        m.full_name                                          AS mentor_name,
        COUNT(e.enrollment_id)                               AS enrollment_count,
        ROUND(COUNT(e.enrollment_id) / b.capacity * 100, 2) AS capacity_used_pct
    FROM
        bootcamps b
        INNER JOIN mentors m     ON b.mentor_id = m.mentor_id
        LEFT  JOIN enrollments e ON b.bootcamp_id = e.bootcamp_id
    GROUP BY
        b.bootcamp_id,
        b.title,
        b.category,
        b.level,
        b.capacity,
        m.full_name
    ORDER BY
        enrollment_count DESC
    LIMIT 5;