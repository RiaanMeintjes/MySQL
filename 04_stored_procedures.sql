-- ============================================================
-- Author:      Riaan Meintjes
-- Date:        2026-03-22
-- Module:      ITMDA0-11 Database Management (MySQL)
-- Project:     1 - Global Coding Bootcamp Platform
-- Purpose:     Create all required stored procedures
-- ============================================================

USE global_bootcamp;

-- Change the delimiter so MySQL does not terminate procedures early
DELIMITER $$

-- ============================================================
-- PROCEDURE: spRegisterLearner
-- Purpose:   Registers a new learner account.
--            Validates that the username and email are unique
--            before inserting the new record.
-- Parameters:
--   p_username        - desired unique username
--   p_password        - plain-text password (hashed inside SP)
--   p_email           - learner email address
--   p_expiry_date     - initial subscription expiry date
--   p_storage_limit   - storage allocation in MB
-- ============================================================
CREATE PROCEDURE spRegisterLearner (
    IN  p_username      VARCHAR(50),
    IN  p_password      VARCHAR(255),
    IN  p_email         VARCHAR(100),
    IN  p_expiry_date   DATE,
    IN  p_storage_limit DECIMAL(10,2)
)
BEGIN
    -- Declare variables for validation
    DECLARE v_username_count INT DEFAULT 0;
    DECLARE v_email_count    INT DEFAULT 0;

    -- Validate: username must not be blank
    IF p_username IS NULL OR TRIM(p_username) = '' THEN
        INSERT INTO error_log (learner_id, error_category, error_message)
        VALUES (NULL, 'Submission Error', 'Registration failed: username cannot be blank.');
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Registration failed: username cannot be blank.';
    END IF;

    -- Validate: password must not be blank
    IF p_password IS NULL OR TRIM(p_password) = '' THEN
        INSERT INTO error_log (learner_id, error_category, error_message)
        VALUES (NULL, 'Submission Error', 'Registration failed: password cannot be blank.');
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Registration failed: password cannot be blank.';
    END IF;

    -- Check for duplicate username
    SELECT COUNT(*) INTO v_username_count
    FROM   learners
    WHERE  username = p_username;

    IF v_username_count > 0 THEN
        INSERT INTO error_log (learner_id, error_category, error_message)
        VALUES (NULL, 'Submission Error',
            CONCAT('Registration failed: username "', p_username, '" is already taken.'));
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Registration failed: username is already taken.';
    END IF;

    -- Check for duplicate email
    SELECT COUNT(*) INTO v_email_count
    FROM   learners
    WHERE  email = p_email;

    IF v_email_count > 0 THEN
        INSERT INTO error_log (learner_id, error_category, error_message)
        VALUES (NULL, 'Submission Error',
            CONCAT('Registration failed: email "', p_email, '" is already registered.'));
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Registration failed: email is already registered.';
    END IF;

    -- All validations passed — insert the new learner
    INSERT INTO learners (username, password, email, account_status, subscription_expiry, storage_limit_mb, storage_used_mb)
    VALUES (
        p_username,
        SHA2(p_password, 256),
        p_email,
        'Active',
        p_expiry_date,
        p_storage_limit,
        0.00
    );

    SELECT CONCAT('Learner "', p_username, '" registered successfully.') AS result;
END$$


-- ============================================================
-- PROCEDURE: spRenewSubscription
-- Purpose:   Renews a learner's subscription by adding a
--            specified number of days. Re-activates blocked
--            accounts upon successful renewal.
-- Parameters:
--   p_learner_id  - ID of the learner to renew
--   p_days_to_add - number of days to extend the subscription
-- ============================================================
CREATE PROCEDURE spRenewSubscription (
    IN p_learner_id  INT,
    IN p_days_to_add INT
)
BEGIN
    DECLARE v_learner_count INT DEFAULT 0;
    DECLARE v_current_expiry DATE;
    DECLARE v_new_expiry     DATE;

    -- Validate: days must be positive
    IF p_days_to_add IS NULL OR p_days_to_add <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Renewal failed: days to add must be a positive number.';
    END IF;

    -- Check learner exists
    SELECT COUNT(*), subscription_expiry
    INTO   v_learner_count, v_current_expiry
    FROM   learners
    WHERE  learner_id = p_learner_id;

    IF v_learner_count = 0 THEN
        INSERT INTO error_log (learner_id, error_category, error_message)
        VALUES (p_learner_id, 'Subscription Failure',
            CONCAT('Renewal failed: learner ID ', p_learner_id, ' not found.'));
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Renewal failed: learner not found.';
    END IF;

    -- Calculate new expiry: extend from today if already expired,
    -- otherwise extend from the current expiry date
    IF v_current_expiry < CURDATE() THEN
        SET v_new_expiry = DATE_ADD(CURDATE(), INTERVAL p_days_to_add DAY);
    ELSE
        SET v_new_expiry = DATE_ADD(v_current_expiry, INTERVAL p_days_to_add DAY);
    END IF;

    -- Update subscription and re-activate the account
    UPDATE learners
    SET    subscription_expiry = v_new_expiry,
           account_status      = 'Active'
    WHERE  learner_id = p_learner_id;

    SELECT CONCAT('Subscription renewed. New expiry date: ', v_new_expiry) AS result;
END$$


-- ============================================================
-- PROCEDURE: spEnrollLearner
-- Purpose:   Enrolls a learner in a bootcamp after checking:
--            1. Learner account is active (not blocked)
--            2. Bootcamp has available capacity
--            3. Learner is not already enrolled
-- Parameters:
--   p_learner_id   - ID of the learner
--   p_bootcamp_id  - ID of the bootcamp to enroll in
-- ============================================================
CREATE PROCEDURE spEnrollLearner (
    IN p_learner_id  INT,
    IN p_bootcamp_id INT
)
BEGIN
    DECLARE v_status          VARCHAR(10);
    DECLARE v_capacity        INT;
    DECLARE v_enrolled_count  INT;
    DECLARE v_already_enrolled INT DEFAULT 0;

    -- Check learner exists and get status
    SELECT account_status
    INTO   v_status
    FROM   learners
    WHERE  learner_id = p_learner_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Enrollment failed: learner not found.';
    END IF;

    -- Check if learner account is active
    IF v_status = 'Blocked' THEN
        INSERT INTO error_log (learner_id, error_category, error_message)
        VALUES (p_learner_id, 'Enrollment Error',
            CONCAT('Enrollment blocked: learner ID ', p_learner_id, ' account is Blocked.'));
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Enrollment failed: learner account is blocked.';
    END IF;

    -- Get bootcamp capacity
    SELECT capacity
    INTO   v_capacity
    FROM   bootcamps
    WHERE  bootcamp_id = p_bootcamp_id;

    IF v_capacity IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Enrollment failed: bootcamp not found.';
    END IF;

    -- Count current enrollments for this bootcamp
    SELECT COUNT(*)
    INTO   v_enrolled_count
    FROM   enrollments
    WHERE  bootcamp_id = p_bootcamp_id;

    -- Check capacity
    IF v_enrolled_count >= v_capacity THEN
        INSERT INTO error_log (learner_id, error_category, error_message)
        VALUES (p_learner_id, 'Enrollment Error',
            CONCAT('Enrollment failed: bootcamp ID ', p_bootcamp_id, ' is at full capacity.'));
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Enrollment failed: bootcamp is at full capacity.';
    END IF;

    -- Check for duplicate enrollment
    SELECT COUNT(*)
    INTO   v_already_enrolled
    FROM   enrollments
    WHERE  learner_id  = p_learner_id
      AND  bootcamp_id = p_bootcamp_id;

    IF v_already_enrolled > 0 THEN
        INSERT INTO error_log (learner_id, error_category, error_message)
        VALUES (p_learner_id, 'Enrollment Error',
            CONCAT('Enrollment failed: learner already enrolled in bootcamp ID ', p_bootcamp_id));
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Enrollment failed: learner is already enrolled in this bootcamp.';
    END IF;

    -- All checks passed — enroll the learner
    INSERT INTO enrollments (learner_id, bootcamp_id)
    VALUES (p_learner_id, p_bootcamp_id);

    SELECT CONCAT('Learner ID ', p_learner_id, ' successfully enrolled in bootcamp ID ', p_bootcamp_id) AS result;
END$$


-- ============================================================
-- PROCEDURE: spAddResource
-- Purpose:   Adds a resource download record for a learner,
--            checking that the learner's storage limit will
--            not be exceeded before adding.
-- Parameters:
--   p_learner_id   - ID of the learner downloading the resource
--   p_resource_id  - ID of the resource to add
-- ============================================================
CREATE PROCEDURE spAddResource (
    IN p_learner_id  INT,
    IN p_resource_id INT
)
BEGIN
    DECLARE v_storage_used  DECIMAL(10,2);
    DECLARE v_storage_limit DECIMAL(10,2);
    DECLARE v_resource_size DECIMAL(10,2);
    DECLARE v_already_added INT DEFAULT 0;

    -- Get learner storage info
    SELECT storage_used_mb, storage_limit_mb
    INTO   v_storage_used, v_storage_limit
    FROM   learners
    WHERE  learner_id = p_learner_id;

    IF v_storage_limit IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Download failed: learner not found.';
    END IF;

    -- Get resource size
    SELECT size_mb
    INTO   v_resource_size
    FROM   resources
    WHERE  resource_id = p_resource_id;

    IF v_resource_size IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Download failed: resource not found.';
    END IF;

    -- Check for duplicate download
    SELECT COUNT(*)
    INTO   v_already_added
    FROM   learner_resources
    WHERE  learner_id  = p_learner_id
      AND  resource_id = p_resource_id;

    IF v_already_added > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Download failed: resource already downloaded by this learner.';
    END IF;

    -- Check storage limit
    IF (v_storage_used + v_resource_size) > v_storage_limit THEN
        INSERT INTO error_log (learner_id, error_category, error_message)
        VALUES (p_learner_id, 'Storage Error',
            CONCAT('Storage limit exceeded for learner ID ', p_learner_id,
                   '. Used: ', v_storage_used, ' MB, Limit: ', v_storage_limit, ' MB, ',
                   'Resource size: ', v_resource_size, ' MB'));
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Download failed: storage limit exceeded.';
    END IF;

    -- Add the download record
    INSERT INTO learner_resources (learner_id, resource_id)
    VALUES (p_learner_id, p_resource_id);

    -- Update learner storage usage and increment download count
    UPDATE learners
    SET    storage_used_mb = storage_used_mb + v_resource_size
    WHERE  learner_id = p_learner_id;

    UPDATE resources
    SET    download_count = download_count + 1
    WHERE  resource_id = p_resource_id;

    SELECT CONCAT('Resource ID ', p_resource_id, ' added successfully. ',
                  'Storage used: ', (v_storage_used + v_resource_size), ' MB') AS result;
END$$


-- ============================================================
-- PROCEDURE: spSendNotice
-- Purpose:   Generates a subscription notice for a learner
--            showing their remaining subscription time and
--            current account status.
-- Parameters:
--   p_learner_id - ID of the learner to generate a notice for
-- ============================================================
CREATE PROCEDURE spSendNotice (
    IN p_learner_id INT
)
BEGIN
    DECLARE v_username        VARCHAR(50);
    DECLARE v_email           VARCHAR(100);
    DECLARE v_status          VARCHAR(10);
    DECLARE v_expiry          DATE;
    DECLARE v_days_remaining  INT;
    DECLARE v_notice_message  VARCHAR(500);

    -- Retrieve learner details
    SELECT username, email, account_status, subscription_expiry
    INTO   v_username, v_email, v_status, v_expiry
    FROM   learners
    WHERE  learner_id = p_learner_id;

    IF v_username IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Notice failed: learner not found.';
    END IF;

    -- Calculate remaining days (negative means expired)
    SET v_days_remaining = DATEDIFF(v_expiry, CURDATE());

    -- Build notice message using CASE for different scenarios
    SET v_notice_message = CASE
        WHEN v_status = 'Blocked' THEN
            CONCAT('ACCOUNT BLOCKED: Dear ', v_username,
                   ', your subscription expired on ', v_expiry,
                   ' (', ABS(v_days_remaining), ' days ago). ',
                   'Please renew to regain access.')
        WHEN v_days_remaining <= 0 THEN
            CONCAT('URGENT: Dear ', v_username,
                   ', your subscription has expired. Please renew immediately.')
        WHEN v_days_remaining <= 7 THEN
            CONCAT('WARNING: Dear ', v_username,
                   ', your subscription expires in ', v_days_remaining, ' day(s) on ', v_expiry,
                   '. Please renew soon.')
        WHEN v_days_remaining <= 30 THEN
            CONCAT('REMINDER: Dear ', v_username,
                   ', your subscription expires in ', v_days_remaining, ' day(s) on ', v_expiry, '.')
        ELSE
            CONCAT('INFO: Dear ', v_username,
                   ', your subscription is active. Expiry date: ', v_expiry,
                   ' (', v_days_remaining, ' days remaining).')
    END;

    -- Return the notice details
    SELECT
        v_username              AS username,
        v_email                 AS email,
        v_status                AS account_status,
        v_expiry                AS subscription_expiry,
        v_days_remaining        AS days_remaining,
        v_notice_message        AS notice_message;
END$$

-- Reset the delimiter back to default
DELIMITER ;
