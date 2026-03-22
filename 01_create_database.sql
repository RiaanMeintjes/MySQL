-- ============================================================
-- Author:      Riaan Meintjes
-- Date:        2026-03-22
-- Module:      ITMDA0-11 Database Management (MySQL)
-- Project:     1 - Global Coding Bootcamp Platform
-- Purpose:     Create the database and all tables with constraints
-- ============================================================

-- Drop and recreate the database for a clean setup
DROP DATABASE IF EXISTS global_bootcamp;
CREATE DATABASE global_bootcamp;
USE global_bootcamp;

-- ============================================================
-- TABLE: learners
-- Purpose: Stores learner account information
-- ============================================================
CREATE TABLE learners (
    learner_id      INT             AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(50)     NOT NULL UNIQUE,
    password        VARCHAR(255)    NOT NULL,
    email           VARCHAR(100)    NOT NULL UNIQUE,
    account_status  ENUM('Active', 'Blocked') NOT NULL DEFAULT 'Active',
    subscription_expiry DATE        NOT NULL,
    storage_limit_mb    DECIMAL(10,2) NOT NULL DEFAULT 500.00,
    storage_used_mb     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_storage_limit   CHECK (storage_limit_mb > 0),
    CONSTRAINT chk_storage_used    CHECK (storage_used_mb >= 0),
    CONSTRAINT chk_storage_not_exceeded CHECK (storage_used_mb <= storage_limit_mb)
);

-- ============================================================
-- TABLE: mentors
-- Purpose: Stores mentor/instructor profile information
-- ============================================================
CREATE TABLE mentors (
    mentor_id       INT             AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100)    NOT NULL,
    email           VARCHAR(100)    NOT NULL UNIQUE,
    specialization  VARCHAR(100)    NOT NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE: bootcamps
-- Purpose: Stores bootcamp (course) information
-- ============================================================
CREATE TABLE bootcamps (
    bootcamp_id     INT             AUTO_INCREMENT PRIMARY KEY,
    title           VARCHAR(150)    NOT NULL,
    category        ENUM('Web', 'Data Science', 'Mobile', 'DevOps', 'Cybersecurity') NOT NULL,
    level           ENUM('Beginner', 'Intermediate', 'Advanced') NOT NULL,
    capacity        INT             NOT NULL,
    mentor_id       INT             NOT NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_capacity CHECK (capacity > 0),
    CONSTRAINT fk_bootcamp_mentor FOREIGN KEY (mentor_id)
        REFERENCES mentors(mentor_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ============================================================
-- TABLE: enrollments
-- Purpose: Tracks which learners are enrolled in which bootcamps
-- ============================================================
CREATE TABLE enrollments (
    enrollment_id   INT             AUTO_INCREMENT PRIMARY KEY,
    learner_id      INT             NOT NULL,
    bootcamp_id     INT             NOT NULL,
    enrolled_at     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_enrollment UNIQUE (learner_id, bootcamp_id),
    CONSTRAINT fk_enrollment_learner FOREIGN KEY (learner_id)
        REFERENCES learners(learner_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_enrollment_bootcamp FOREIGN KEY (bootcamp_id)
        REFERENCES bootcamps(bootcamp_id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- TABLE: modules
-- Purpose: Stores individual learning modules within a bootcamp
-- ============================================================
CREATE TABLE modules (
    module_id       INT             AUTO_INCREMENT PRIMARY KEY,
    bootcamp_id     INT             NOT NULL,
    title           VARCHAR(150)    NOT NULL,
    module_order    INT             NOT NULL DEFAULT 1,
    CONSTRAINT chk_module_order CHECK (module_order > 0),
    CONSTRAINT fk_module_bootcamp FOREIGN KEY (bootcamp_id)
        REFERENCES bootcamps(bootcamp_id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- TABLE: module_progress
-- Purpose: Tracks each learner's progress per module
-- ============================================================
CREATE TABLE module_progress (
    progress_id         INT             AUTO_INCREMENT PRIMARY KEY,
    learner_id          INT             NOT NULL,
    module_id           INT             NOT NULL,
    completion_status   ENUM('Not Started', 'In Progress', 'Completed') NOT NULL DEFAULT 'Not Started',
    progress_percentage DECIMAL(5,2)    NOT NULL DEFAULT 0.00,
    skill_points        INT             NOT NULL DEFAULT 0,
    last_updated        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_module_progress UNIQUE (learner_id, module_id),
    CONSTRAINT chk_progress_pct CHECK (progress_percentage BETWEEN 0 AND 100),
    CONSTRAINT chk_skill_points CHECK (skill_points >= 0),
    CONSTRAINT fk_progress_learner FOREIGN KEY (learner_id)
        REFERENCES learners(learner_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_progress_module FOREIGN KEY (module_id)
        REFERENCES modules(module_id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- TABLE: assessments
-- Purpose: Stores assessments linked to bootcamps
-- ============================================================
CREATE TABLE assessments (
    assessment_id   INT             AUTO_INCREMENT PRIMARY KEY,
    bootcamp_id     INT             NOT NULL,
    title           VARCHAR(150)    NOT NULL,
    assessment_type ENUM('Quiz', 'Coding Challenge', 'Project') NOT NULL,
    CONSTRAINT fk_assessment_bootcamp FOREIGN KEY (bootcamp_id)
        REFERENCES bootcamps(bootcamp_id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- TABLE: assessment_results
-- Purpose: Records learner marks and skill scores per assessment
-- ============================================================
CREATE TABLE assessment_results (
    result_id       INT             AUTO_INCREMENT PRIMARY KEY,
    learner_id      INT             NOT NULL,
    assessment_id   INT             NOT NULL,
    marks_obtained  DECIMAL(5,2)    NOT NULL DEFAULT 0,
    skill_score     INT             NOT NULL DEFAULT 0,
    submitted_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_assessment_result UNIQUE (learner_id, assessment_id),
    CONSTRAINT chk_marks CHECK (marks_obtained BETWEEN 0 AND 100),
    CONSTRAINT chk_skill_score CHECK (skill_score >= 0),
    CONSTRAINT fk_result_learner FOREIGN KEY (learner_id)
        REFERENCES learners(learner_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_result_assessment FOREIGN KEY (assessment_id)
        REFERENCES assessments(assessment_id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- TABLE: resources
-- Purpose: Stores digital learning resources
-- ============================================================
CREATE TABLE resources (
    resource_id     INT             AUTO_INCREMENT PRIMARY KEY,
    bootcamp_id     INT             NOT NULL,
    title           VARCHAR(150)    NOT NULL,
    resource_type   ENUM('PDF', 'Video', 'Slides', 'Code Sample') NOT NULL,
    size_mb         DECIMAL(10,2)   NOT NULL,
    download_count  INT             NOT NULL DEFAULT 0,
    uploaded_at     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_resource_size CHECK (size_mb > 0),
    CONSTRAINT chk_download_count CHECK (download_count >= 0),
    CONSTRAINT fk_resource_bootcamp FOREIGN KEY (bootcamp_id)
        REFERENCES bootcamps(bootcamp_id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- TABLE: learner_resources
-- Purpose: Links learners to resources they have downloaded
-- ============================================================
CREATE TABLE learner_resources (
    lr_id           INT             AUTO_INCREMENT PRIMARY KEY,
    learner_id      INT             NOT NULL,
    resource_id     INT             NOT NULL,
    downloaded_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_learner_resource UNIQUE (learner_id, resource_id),
    CONSTRAINT fk_lr_learner FOREIGN KEY (learner_id)
        REFERENCES learners(learner_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_lr_resource FOREIGN KEY (resource_id)
        REFERENCES resources(resource_id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- TABLE: error_log
-- Purpose: Logs system errors and failed actions
-- ============================================================
CREATE TABLE error_log (
    log_id          INT             AUTO_INCREMENT PRIMARY KEY,
    learner_id      INT             NULL,
    error_category  ENUM('Login Failure', 'Submission Error', 'Payment Failure', 'Subscription Failure', 'Enrollment Error', 'Storage Error') NOT NULL,
    error_message   VARCHAR(500)    NOT NULL,
    logged_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_learner FOREIGN KEY (learner_id)
        REFERENCES learners(learner_id) ON UPDATE CASCADE ON DELETE SET NULL
);
