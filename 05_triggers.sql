-- ============================================================
-- Author:      Riaan Meintjes
-- Date:        2026-03-22
-- Module:      ITMDA0-11 Database Management (MySQL)
-- Project:     1 - Global Coding Bootcamp Platform
-- Purpose:     Create all required triggers
-- ============================================================

USE global_bootcamp;

DELIMITER $$

-- ============================================================
-- TRIGGER: trg_block_expired_learner_insert
-- Purpose:  Automatically sets a learner's account status to
--           'Blocked' when a new learner is inserted with a
--           subscription_expiry date that is already in the past.
--           This handles backdated data entry scenarios.
-- ============================================================
CREATE TRIGGER trg_block_expired_learner_insert
    BEFORE INSERT ON learners
    FOR EACH ROW
BEGIN
    IF NEW.subscription_expiry < CURDATE() THEN
        SET NEW.account_status = 'Blocked';
    END IF;
END$$


-- ============================================================
-- TRIGGER: trg_block_expired_learner_update
-- Purpose:  Automatically sets a learner's account status to
--           'Blocked' when their subscription_expiry is updated
--           to a date in the past (e.g., no renewal made).
--           Also logs the automatic blocking event.
-- ============================================================
CREATE TRIGGER trg_block_expired_learner_update
    BEFORE UPDATE ON learners
    FOR EACH ROW
BEGIN
    -- Only block if the subscription_expiry has moved to a past date
    -- and the account is currently Active
    IF NEW.subscription_expiry < CURDATE()
       AND NEW.account_status = 'Active' THEN

        SET NEW.account_status = 'Blocked';

    END IF;
END$$


-- ============================================================
-- TRIGGER: trg_log_learner_blocked
-- Purpose:  After a learner's status changes to 'Blocked',
--           log the blocking event in the error_log table
--           for audit purposes.
-- ============================================================
CREATE TRIGGER trg_log_learner_blocked
    AFTER UPDATE ON learners
    FOR EACH ROW
BEGIN
    -- Log when an account transitions from Active to Blocked
    IF NEW.account_status = 'Blocked'
       AND OLD.account_status = 'Active' THEN

        INSERT INTO error_log (learner_id, error_category, error_message)
        VALUES (
            NEW.learner_id,
            'Subscription Failure',
            CONCAT('Account blocked automatically. Subscription expired on: ',
                   NEW.subscription_expiry)
        );
    END IF;
END$$


-- ============================================================
-- TRIGGER: trg_log_failed_enrollment_capacity
-- Purpose:  Logs an error when an enrollment insert would
--           violate capacity, providing an audit trail of
--           all blocked enrollment attempts.
--           NOTE: The capacity check is enforced in the
--           stored procedure; this trigger logs events after
--           successful inserts and tracks enrollment growth.
-- ============================================================
CREATE TRIGGER trg_log_enrollment_insert
    AFTER INSERT ON enrollments
    FOR EACH ROW
BEGIN
    DECLARE v_enrolled_count INT;
    DECLARE v_capacity       INT;

    -- Count current enrollments for this bootcamp (including this new one)
    SELECT COUNT(*), b.capacity
    INTO   v_enrolled_count, v_capacity
    FROM   enrollments e
           INNER JOIN bootcamps b ON e.bootcamp_id = b.bootcamp_id
    WHERE  e.bootcamp_id = NEW.bootcamp_id;

    -- Log a warning if the bootcamp is now at 80% or above capacity
    IF v_enrolled_count >= FLOOR(v_capacity * 0.80) THEN
        INSERT INTO error_log (learner_id, error_category, error_message)
        VALUES (
            NEW.learner_id,
            'Enrollment Error',
            CONCAT('Capacity alert: Bootcamp ID ', NEW.bootcamp_id,
                   ' is at ', v_enrolled_count, '/', v_capacity, ' learners (',
                   ROUND(v_enrolled_count / v_capacity * 100, 0), '% full).')
        );
    END IF;
END$$


-- ============================================================
-- TRIGGER: trg_log_resource_storage_warning
-- Purpose:  After a resource is downloaded (learner_resources
--           insert), log a warning if the learner's storage is
--           at 90% or more of their limit.
-- ============================================================
CREATE TRIGGER trg_log_storage_warning
    AFTER INSERT ON learner_resources
    FOR EACH ROW
BEGIN
    DECLARE v_used  DECIMAL(10,2);
    DECLARE v_limit DECIMAL(10,2);

    SELECT storage_used_mb, storage_limit_mb
    INTO   v_used, v_limit
    FROM   learners
    WHERE  learner_id = NEW.learner_id;

    IF (v_used / v_limit) >= 0.90 THEN
        INSERT INTO error_log (learner_id, error_category, error_message)
        VALUES (
            NEW.learner_id,
            'Storage Error',
            CONCAT('Storage warning: Learner ID ', NEW.learner_id,
                   ' is using ', v_used, ' MB of ', v_limit, ' MB (',
                   ROUND(v_used / v_limit * 100, 1), '%).')
        );
    END IF;
END$$


-- ============================================================
-- TRIGGER: trg_log_assessment_submission
-- Purpose:  Logs every assessment submission for auditing.
--           Records the learner and marks after each result insert.
-- ============================================================
CREATE TRIGGER trg_log_assessment_submission
    AFTER INSERT ON assessment_results
    FOR EACH ROW
BEGIN
    -- Log a submission error event if marks are below 50
    IF NEW.marks_obtained < 50.00 THEN
        INSERT INTO error_log (learner_id, error_category, error_message)
        VALUES (
            NEW.learner_id,
            'Submission Error',
            CONCAT('Low score alert: Learner ID ', NEW.learner_id,
                   ' scored ', NEW.marks_obtained, '% on assessment ID ', NEW.assessment_id, '.')
        );
    END IF;
END$$

DELIMITER ;
