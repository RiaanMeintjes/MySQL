-- ============================================================
-- Author:      Riaan Meintjes
-- Date:        2026-03-22
-- Module:      ITMDA0-11 Database Management (MySQL)
-- Project:     1 - Global Coding Bootcamp Platform
-- Purpose:     Insert sample data into all tables
-- ============================================================

USE global_bootcamp;

-- ============================================================
-- INSERT: mentors (3 mentors)
-- ============================================================
INSERT INTO mentors (full_name, email, specialization)
VALUES
    ('Alice Mokoena',   'alice.mokoena@bootcamp.com',   'Web Development'),
    ('Brian Nkosi',     'brian.nkosi@bootcamp.com',     'Data Science'),
    ('Carla Ferreira',  'carla.ferreira@bootcamp.com',  'Mobile Development');

-- ============================================================
-- INSERT: learners (5 learners)
-- subscription_expiry deliberately set in the past for some
-- to allow trigger and view testing
-- ============================================================
INSERT INTO learners (username, password, email, account_status, subscription_expiry, storage_limit_mb, storage_used_mb)
VALUES
    ('jdoe',        SHA2('Pass@123', 256),  'jdoe@mail.com',        'Active',   '2026-12-31',  500.00,  45.50),
    ('smith_s',     SHA2('Pass@456', 256),  'smsmith@mail.com',     'Active',   '2026-09-15',  500.00,  120.00),
    ('lkhumalo',    SHA2('Khumalo1!', 256), 'lkhumalo@mail.com',    'Blocked',  '2025-12-01',  500.00,  80.00),
    ('tpatel',      SHA2('Patel@99', 256),  'tpatel@mail.com',      'Active',   '2026-11-30',  1000.00, 250.00),
    ('mvanwyk',     SHA2('Van@2026', 256),  'mvanwyk@mail.com',     'Active',   '2026-06-20',  500.00,  10.00),
    ('nzulu',       SHA2('Zulu@321', 256),  'nzulu@mail.com',       'Blocked',  '2025-11-01',  500.00,  200.00),
    ('rjones',      SHA2('Jones#77', 256),  'rjones@mail.com',      'Active',   '2026-08-10',  750.00,  300.00);

-- ============================================================
-- INSERT: bootcamps (5 bootcamps)
-- ============================================================
INSERT INTO bootcamps (title, category, level, capacity, mentor_id)
VALUES
    ('HTML & CSS Fundamentals',     'Web',          'Beginner',     30, 1),
    ('JavaScript Full Stack',       'Web',          'Intermediate', 25, 1),
    ('Python for Data Analysis',    'Data Science', 'Beginner',     20, 2),
    ('Machine Learning Essentials', 'Data Science', 'Advanced',     15, 2),
    ('Android App Development',     'Mobile',       'Intermediate', 20, 3);

-- ============================================================
-- INSERT: modules (3 modules per bootcamp)
-- ============================================================
INSERT INTO modules (bootcamp_id, title, module_order)
VALUES
    (1, 'Introduction to HTML',         1),
    (1, 'Styling with CSS',             2),
    (1, 'Responsive Design',            3),
    (2, 'JavaScript Basics',            1),
    (2, 'Node.js & Express',            2),
    (2, 'React Fundamentals',           3),
    (3, 'Python Syntax & Data Types',   1),
    (3, 'Pandas & NumPy',               2),
    (3, 'Data Visualisation',           3),
    (4, 'ML Concepts & Algorithms',     1),
    (4, 'Model Training & Evaluation',  2),
    (4, 'Deep Learning Intro',          3),
    (5, 'Android Studio Setup',         1),
    (5, 'Layouts & UI Components',      2),
    (5, 'APIs & Backend Integration',   3);

-- ============================================================
-- INSERT: enrollments
-- ============================================================
INSERT INTO enrollments (learner_id, bootcamp_id)
VALUES
    (1, 1), (1, 2),
    (2, 1), (2, 3),
    (3, 2),
    (4, 3), (4, 4),
    (5, 5),
    (6, 1),
    (7, 2), (7, 4), (7, 5);

-- ============================================================
-- INSERT: module_progress
-- ============================================================
INSERT INTO module_progress (learner_id, module_id, completion_status, progress_percentage, skill_points)
VALUES
    (1, 1, 'Completed',     100.00, 50),
    (1, 2, 'In Progress',    65.00, 30),
    (1, 4, 'Not Started',     0.00,  0),
    (2, 1, 'Completed',     100.00, 50),
    (2, 2, 'Completed',     100.00, 50),
    (2, 7, 'In Progress',    40.00, 20),
    (4, 7, 'Completed',     100.00, 50),
    (4, 8, 'In Progress',    55.00, 25),
    (4, 10,'Not Started',     0.00,  0),
    (7, 4, 'Completed',     100.00, 50),
    (7, 5, 'Completed',     100.00, 50),
    (7, 6, 'In Progress',    80.00, 40);

-- ============================================================
-- INSERT: assessments
-- ============================================================
INSERT INTO assessments (bootcamp_id, title, assessment_type)
VALUES
    (1, 'HTML Basics Quiz',             'Quiz'),
    (1, 'CSS Layout Challenge',         'Coding Challenge'),
    (2, 'JS Functions Project',         'Project'),
    (2, 'REST API Quiz',                'Quiz'),
    (3, 'Python Syntax Quiz',           'Quiz'),
    (3, 'Pandas Data Cleaning Project', 'Project'),
    (4, 'ML Algorithm Quiz',            'Quiz'),
    (4, 'Model Accuracy Challenge',     'Coding Challenge'),
    (5, 'Android UI Quiz',              'Quiz'),
    (5, 'App Build Project',            'Project');

-- ============================================================
-- INSERT: assessment_results
-- ============================================================
INSERT INTO assessment_results (learner_id, assessment_id, marks_obtained, skill_score)
VALUES
    (1, 1, 88.00, 45),
    (1, 2, 76.00, 38),
    (2, 1, 92.00, 46),
    (2, 2, 85.00, 43),
    (2, 5, 78.00, 39),
    (4, 5, 95.00, 48),
    (4, 6, 90.00, 45),
    (4, 7, 72.00, 36),
    (7, 3, 88.00, 44),
    (7, 4, 91.00, 46),
    (7, 7, 85.00, 43),
    (7, 8, 80.00, 40);

-- ============================================================
-- INSERT: resources
-- ============================================================
INSERT INTO resources (bootcamp_id, title, resource_type, size_mb, download_count)
VALUES
    (1, 'HTML Cheat Sheet',             'PDF',          1.20,  320),
    (1, 'CSS Grid Tutorial Video',      'Video',        85.00, 210),
    (2, 'JavaScript Notes',             'PDF',          2.50,  185),
    (2, 'React Starter Code',           'Code Sample',  5.00,  150),
    (3, 'Python Basics Slides',         'Slides',       3.80,  400),
    (3, 'NumPy Reference PDF',          'PDF',          1.60,  290),
    (4, 'ML Algorithm Slides',          'Slides',       4.20,  175),
    (4, 'Scikit-learn Code Samples',    'Code Sample',  8.00,  220),
    (5, 'Android Studio Setup Guide',   'PDF',          2.10,  130),
    (5, 'Mobile UI Templates',          'Code Sample',  12.00, 95);

-- ============================================================
-- INSERT: learner_resources (simulate downloads, storage is updated via stored procedure)
-- ============================================================
INSERT INTO learner_resources (learner_id, resource_id)
VALUES
    (1, 1), (1, 2),
    (2, 1), (2, 3),
    (4, 5), (4, 6), (4, 7),
    (7, 3), (7, 4), (7, 8);
