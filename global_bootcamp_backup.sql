CREATE DATABASE  IF NOT EXISTS `global_bootcamp` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `global_bootcamp`;
-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: global_bootcamp
-- ------------------------------------------------------
-- Server version	5.7.13-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `assessment_results`
--

DROP TABLE IF EXISTS `assessment_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assessment_results` (
  `result_id` int(11) NOT NULL AUTO_INCREMENT,
  `learner_id` int(11) NOT NULL,
  `assessment_id` int(11) NOT NULL,
  `marks_obtained` decimal(5,2) NOT NULL DEFAULT '0.00',
  `skill_score` int(11) NOT NULL DEFAULT '0',
  `submitted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`result_id`),
  UNIQUE KEY `uq_assessment_result` (`learner_id`,`assessment_id`),
  KEY `idx_results_learner` (`learner_id`),
  KEY `idx_results_assessment` (`assessment_id`),
  KEY `idx_results_skill_score` (`skill_score`),
  CONSTRAINT `fk_result_assessment` FOREIGN KEY (`assessment_id`) REFERENCES `assessments` (`assessment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_result_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assessment_results`
--

LOCK TABLES `assessment_results` WRITE;
/*!40000 ALTER TABLE `assessment_results` DISABLE KEYS */;
INSERT INTO `assessment_results` VALUES (1,1,1,88.00,45,'2026-03-22 12:14:52'),(2,1,2,76.00,38,'2026-03-22 12:14:52'),(3,2,1,92.00,46,'2026-03-22 12:14:52'),(4,2,2,85.00,43,'2026-03-22 12:14:52'),(5,2,5,78.00,39,'2026-03-22 12:14:52'),(6,4,5,95.00,48,'2026-03-22 12:14:52'),(7,4,6,90.00,45,'2026-03-22 12:14:52'),(8,4,7,72.00,36,'2026-03-22 12:14:52'),(9,7,3,88.00,44,'2026-03-22 12:14:52'),(10,7,4,91.00,46,'2026-03-22 12:14:52'),(11,7,7,85.00,43,'2026-03-22 12:14:52'),(12,7,8,80.00,40,'2026-03-22 12:14:52');
/*!40000 ALTER TABLE `assessment_results` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_log_assessment_submission
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `assessments`
--

DROP TABLE IF EXISTS `assessments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assessments` (
  `assessment_id` int(11) NOT NULL AUTO_INCREMENT,
  `bootcamp_id` int(11) NOT NULL,
  `title` varchar(150) NOT NULL,
  `assessment_type` enum('Quiz','Coding Challenge','Project') NOT NULL,
  PRIMARY KEY (`assessment_id`),
  KEY `fk_assessment_bootcamp` (`bootcamp_id`),
  CONSTRAINT `fk_assessment_bootcamp` FOREIGN KEY (`bootcamp_id`) REFERENCES `bootcamps` (`bootcamp_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assessments`
--

LOCK TABLES `assessments` WRITE;
/*!40000 ALTER TABLE `assessments` DISABLE KEYS */;
INSERT INTO `assessments` VALUES (1,1,'HTML Basics Quiz','Quiz'),(2,1,'CSS Layout Challenge','Coding Challenge'),(3,2,'JS Functions Project','Project'),(4,2,'REST API Quiz','Quiz'),(5,3,'Python Syntax Quiz','Quiz'),(6,3,'Pandas Data Cleaning Project','Project'),(7,4,'ML Algorithm Quiz','Quiz'),(8,4,'Model Accuracy Challenge','Coding Challenge'),(9,5,'Android UI Quiz','Quiz'),(10,5,'App Build Project','Project');
/*!40000 ALTER TABLE `assessments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bootcamps`
--

DROP TABLE IF EXISTS `bootcamps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bootcamps` (
  `bootcamp_id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(150) NOT NULL,
  `category` enum('Web','Data Science','Mobile','DevOps','Cybersecurity') NOT NULL,
  `level` enum('Beginner','Intermediate','Advanced') NOT NULL,
  `capacity` int(11) NOT NULL,
  `mentor_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bootcamp_id`),
  KEY `idx_bootcamps_category` (`category`),
  KEY `idx_bootcamps_level` (`level`),
  KEY `idx_bootcamps_mentor` (`mentor_id`),
  CONSTRAINT `fk_bootcamp_mentor` FOREIGN KEY (`mentor_id`) REFERENCES `mentors` (`mentor_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bootcamps`
--

LOCK TABLES `bootcamps` WRITE;
/*!40000 ALTER TABLE `bootcamps` DISABLE KEYS */;
INSERT INTO `bootcamps` VALUES (1,'HTML & CSS Fundamentals','Web','Beginner',30,1,'2026-03-22 12:14:52'),(2,'JavaScript Full Stack','Web','Intermediate',25,1,'2026-03-22 12:14:52'),(3,'Python for Data Analysis','Data Science','Beginner',20,2,'2026-03-22 12:14:52'),(4,'Machine Learning Essentials','Data Science','Advanced',15,2,'2026-03-22 12:14:52'),(5,'Android App Development','Mobile','Intermediate',20,3,'2026-03-22 12:14:52');
/*!40000 ALTER TABLE `bootcamps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enrollments`
--

DROP TABLE IF EXISTS `enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `enrollments` (
  `enrollment_id` int(11) NOT NULL AUTO_INCREMENT,
  `learner_id` int(11) NOT NULL,
  `bootcamp_id` int(11) NOT NULL,
  `enrolled_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`enrollment_id`),
  UNIQUE KEY `uq_enrollment` (`learner_id`,`bootcamp_id`),
  KEY `idx_enrollments_learner` (`learner_id`),
  KEY `idx_enrollments_bootcamp` (`bootcamp_id`),
  CONSTRAINT `fk_enrollment_bootcamp` FOREIGN KEY (`bootcamp_id`) REFERENCES `bootcamps` (`bootcamp_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_enrollment_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enrollments`
--

LOCK TABLES `enrollments` WRITE;
/*!40000 ALTER TABLE `enrollments` DISABLE KEYS */;
INSERT INTO `enrollments` VALUES (1,1,1,'2026-03-22 12:14:52'),(2,1,2,'2026-03-22 12:14:52'),(3,2,1,'2026-03-22 12:14:52'),(4,2,3,'2026-03-22 12:14:52'),(5,3,2,'2026-03-22 12:14:52'),(6,4,3,'2026-03-22 12:14:52'),(7,4,4,'2026-03-22 12:14:52'),(8,5,5,'2026-03-22 12:14:52'),(9,6,1,'2026-03-22 12:14:52'),(10,7,2,'2026-03-22 12:14:52'),(11,7,4,'2026-03-22 12:14:52'),(12,7,5,'2026-03-22 12:14:52');
/*!40000 ALTER TABLE `enrollments` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_log_enrollment_insert
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `error_log`
--

DROP TABLE IF EXISTS `error_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `error_log` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `learner_id` int(11) DEFAULT NULL,
  `error_category` enum('Login Failure','Submission Error','Payment Failure','Subscription Failure','Enrollment Error','Storage Error') NOT NULL,
  `error_message` varchar(500) NOT NULL,
  `logged_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_errorlog_learner` (`learner_id`),
  KEY `idx_errorlog_category` (`error_category`),
  KEY `idx_errorlog_timestamp` (`logged_at`),
  CONSTRAINT `fk_log_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `error_log`
--

LOCK TABLES `error_log` WRITE;
/*!40000 ALTER TABLE `error_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `error_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `learner_resources`
--

DROP TABLE IF EXISTS `learner_resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `learner_resources` (
  `lr_id` int(11) NOT NULL AUTO_INCREMENT,
  `learner_id` int(11) NOT NULL,
  `resource_id` int(11) NOT NULL,
  `downloaded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`lr_id`),
  UNIQUE KEY `uq_learner_resource` (`learner_id`,`resource_id`),
  KEY `fk_lr_resource` (`resource_id`),
  CONSTRAINT `fk_lr_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_lr_resource` FOREIGN KEY (`resource_id`) REFERENCES `resources` (`resource_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `learner_resources`
--

LOCK TABLES `learner_resources` WRITE;
/*!40000 ALTER TABLE `learner_resources` DISABLE KEYS */;
INSERT INTO `learner_resources` VALUES (1,1,1,'2026-03-22 12:14:52'),(2,1,2,'2026-03-22 12:14:52'),(3,2,1,'2026-03-22 12:14:52'),(4,2,3,'2026-03-22 12:14:52'),(5,4,5,'2026-03-22 12:14:52'),(6,4,6,'2026-03-22 12:14:52'),(7,4,7,'2026-03-22 12:14:52'),(8,7,3,'2026-03-22 12:14:52'),(9,7,4,'2026-03-22 12:14:52'),(10,7,8,'2026-03-22 12:14:52');
/*!40000 ALTER TABLE `learner_resources` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_log_storage_warning
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `learners`
--

DROP TABLE IF EXISTS `learners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `learners` (
  `learner_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `account_status` enum('Active','Blocked') NOT NULL DEFAULT 'Active',
  `subscription_expiry` date NOT NULL,
  `storage_limit_mb` decimal(10,2) NOT NULL DEFAULT '500.00',
  `storage_used_mb` decimal(10,2) NOT NULL DEFAULT '0.00',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`learner_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_learners_username` (`username`),
  KEY `idx_learners_email` (`email`),
  KEY `idx_learners_status_expiry` (`account_status`,`subscription_expiry`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `learners`
--

LOCK TABLES `learners` WRITE;
/*!40000 ALTER TABLE `learners` DISABLE KEYS */;
INSERT INTO `learners` VALUES (1,'jdoe','b6bc7b58510319a151d168ba3d5aecb3ac0a9708d06dd930f37fbc89b6cdc697','jdoe@mail.com','Active','2026-12-31',500.00,45.50,'2026-03-22 12:14:52'),(2,'smith_s','598e6e91df8116369839af855a7ccebd3610d51f5aafd65ef5c2cafac9a2da7d','smsmith@mail.com','Active','2026-09-15',500.00,120.00,'2026-03-22 12:14:52'),(3,'lkhumalo','3ab92292e2be1a210787cc57f005bd27e3fe40672cf8d3832a4d18ccf70c38b9','lkhumalo@mail.com','Blocked','2025-12-01',500.00,80.00,'2026-03-22 12:14:52'),(4,'tpatel','6cadd1a14e1839d1c4b8c580dd11fd50387f41d96b1aee81be3e05fbd2f22e1d','tpatel@mail.com','Active','2026-11-30',1000.00,250.00,'2026-03-22 12:14:52'),(5,'mvanwyk','5372030cde3e935d042c99c4d6e4a31c2a73c0291a04aea47fbb1630b08f5df0','mvanwyk@mail.com','Active','2026-06-20',500.00,10.00,'2026-03-22 12:14:52'),(6,'nzulu','fc1a47e585f787a025c89940f570a3cc5c929040c203a2ac30a41ceb2e34c848','nzulu@mail.com','Blocked','2025-11-01',500.00,200.00,'2026-03-22 12:14:52'),(7,'rjones','5930618bd11e47d2cf3708bcf1dcea40b5555f1514facae78b74253657538b90','rjones@mail.com','Active','2026-08-10',750.00,300.00,'2026-03-22 12:14:52');
/*!40000 ALTER TABLE `learners` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_block_expired_learner_insert
    BEFORE INSERT ON learners
    FOR EACH ROW
BEGIN
    IF NEW.subscription_expiry < CURDATE() THEN
        SET NEW.account_status = 'Blocked';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_block_expired_learner_update
    BEFORE UPDATE ON learners
    FOR EACH ROW
BEGIN
    -- Only block if the subscription_expiry has moved to a past date
    -- and the account is currently Active
    IF NEW.subscription_expiry < CURDATE()
       AND NEW.account_status = 'Active' THEN

        SET NEW.account_status = 'Blocked';

    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_log_learner_blocked
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `mentors`
--

DROP TABLE IF EXISTS `mentors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mentors` (
  `mentor_id` int(11) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `specialization` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`mentor_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mentors`
--

LOCK TABLES `mentors` WRITE;
/*!40000 ALTER TABLE `mentors` DISABLE KEYS */;
INSERT INTO `mentors` VALUES (1,'Alice Mokoena','alice.mokoena@bootcamp.com','Web Development','2026-03-22 12:14:52'),(2,'Brian Nkosi','brian.nkosi@bootcamp.com','Data Science','2026-03-22 12:14:52'),(3,'Carla Ferreira','carla.ferreira@bootcamp.com','Mobile Development','2026-03-22 12:14:52');
/*!40000 ALTER TABLE `mentors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `module_progress`
--

DROP TABLE IF EXISTS `module_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `module_progress` (
  `progress_id` int(11) NOT NULL AUTO_INCREMENT,
  `learner_id` int(11) NOT NULL,
  `module_id` int(11) NOT NULL,
  `completion_status` enum('Not Started','In Progress','Completed') NOT NULL DEFAULT 'Not Started',
  `progress_percentage` decimal(5,2) NOT NULL DEFAULT '0.00',
  `skill_points` int(11) NOT NULL DEFAULT '0',
  `last_updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`progress_id`),
  UNIQUE KEY `uq_module_progress` (`learner_id`,`module_id`),
  KEY `idx_progress_learner` (`learner_id`),
  KEY `idx_progress_module` (`module_id`),
  CONSTRAINT `fk_progress_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_progress_module` FOREIGN KEY (`module_id`) REFERENCES `modules` (`module_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `module_progress`
--

LOCK TABLES `module_progress` WRITE;
/*!40000 ALTER TABLE `module_progress` DISABLE KEYS */;
INSERT INTO `module_progress` VALUES (1,1,1,'Completed',100.00,50,'2026-03-22 12:14:52'),(2,1,2,'In Progress',65.00,30,'2026-03-22 12:14:52'),(3,1,4,'Not Started',0.00,0,'2026-03-22 12:14:52'),(4,2,1,'Completed',100.00,50,'2026-03-22 12:14:52'),(5,2,2,'Completed',100.00,50,'2026-03-22 12:14:52'),(6,2,7,'In Progress',40.00,20,'2026-03-22 12:14:52'),(7,4,7,'Completed',100.00,50,'2026-03-22 12:14:52'),(8,4,8,'In Progress',55.00,25,'2026-03-22 12:14:52'),(9,4,10,'Not Started',0.00,0,'2026-03-22 12:14:52'),(10,7,4,'Completed',100.00,50,'2026-03-22 12:14:52'),(11,7,5,'Completed',100.00,50,'2026-03-22 12:14:52'),(12,7,6,'In Progress',80.00,40,'2026-03-22 12:14:52');
/*!40000 ALTER TABLE `module_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `modules`
--

DROP TABLE IF EXISTS `modules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `modules` (
  `module_id` int(11) NOT NULL AUTO_INCREMENT,
  `bootcamp_id` int(11) NOT NULL,
  `title` varchar(150) NOT NULL,
  `module_order` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`module_id`),
  KEY `fk_module_bootcamp` (`bootcamp_id`),
  CONSTRAINT `fk_module_bootcamp` FOREIGN KEY (`bootcamp_id`) REFERENCES `bootcamps` (`bootcamp_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `modules`
--

LOCK TABLES `modules` WRITE;
/*!40000 ALTER TABLE `modules` DISABLE KEYS */;
INSERT INTO `modules` VALUES (1,1,'Introduction to HTML',1),(2,1,'Styling with CSS',2),(3,1,'Responsive Design',3),(4,2,'JavaScript Basics',1),(5,2,'Node.js & Express',2),(6,2,'React Fundamentals',3),(7,3,'Python Syntax & Data Types',1),(8,3,'Pandas & NumPy',2),(9,3,'Data Visualisation',3),(10,4,'ML Concepts & Algorithms',1),(11,4,'Model Training & Evaluation',2),(12,4,'Deep Learning Intro',3),(13,5,'Android Studio Setup',1),(14,5,'Layouts & UI Components',2),(15,5,'APIs & Backend Integration',3);
/*!40000 ALTER TABLE `modules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resources`
--

DROP TABLE IF EXISTS `resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resources` (
  `resource_id` int(11) NOT NULL AUTO_INCREMENT,
  `bootcamp_id` int(11) NOT NULL,
  `title` varchar(150) NOT NULL,
  `resource_type` enum('PDF','Video','Slides','Code Sample') NOT NULL,
  `size_mb` decimal(10,2) NOT NULL,
  `download_count` int(11) NOT NULL DEFAULT '0',
  `uploaded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`resource_id`),
  KEY `idx_resources_bootcamp` (`bootcamp_id`),
  KEY `idx_resources_downloads` (`download_count`),
  KEY `idx_resources_type` (`resource_type`),
  CONSTRAINT `fk_resource_bootcamp` FOREIGN KEY (`bootcamp_id`) REFERENCES `bootcamps` (`bootcamp_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resources`
--

LOCK TABLES `resources` WRITE;
/*!40000 ALTER TABLE `resources` DISABLE KEYS */;
INSERT INTO `resources` VALUES (1,1,'HTML Cheat Sheet','PDF',1.20,320,'2026-03-22 12:14:52'),(2,1,'CSS Grid Tutorial Video','Video',85.00,210,'2026-03-22 12:14:52'),(3,2,'JavaScript Notes','PDF',2.50,185,'2026-03-22 12:14:52'),(4,2,'React Starter Code','Code Sample',5.00,150,'2026-03-22 12:14:52'),(5,3,'Python Basics Slides','Slides',3.80,400,'2026-03-22 12:14:52'),(6,3,'NumPy Reference PDF','PDF',1.60,290,'2026-03-22 12:14:52'),(7,4,'ML Algorithm Slides','Slides',4.20,175,'2026-03-22 12:14:52'),(8,4,'Scikit-learn Code Samples','Code Sample',8.00,220,'2026-03-22 12:14:52'),(9,5,'Android Studio Setup Guide','PDF',2.10,130,'2026-03-22 12:14:52'),(10,5,'Mobile UI Templates','Code Sample',12.00,95,'2026-03-22 12:14:52');
/*!40000 ALTER TABLE `resources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vwblockedlearners`
--

DROP TABLE IF EXISTS `vwblockedlearners`;
/*!50001 DROP VIEW IF EXISTS `vwblockedlearners`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vwblockedlearners` AS SELECT 
 1 AS `learner_id`,
 1 AS `username`,
 1 AS `email`,
 1 AS `account_status`,
 1 AS `subscription_expiry`,
 1 AS `days_overdue`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vwmostdownloadedresources`
--

DROP TABLE IF EXISTS `vwmostdownloadedresources`;
/*!50001 DROP VIEW IF EXISTS `vwmostdownloadedresources`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vwmostdownloadedresources` AS SELECT 
 1 AS `resource_id`,
 1 AS `resource_title`,
 1 AS `resource_type`,
 1 AS `size_mb`,
 1 AS `download_count`,
 1 AS `bootcamp_title`,
 1 AS `bootcamp_category`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vwpopularbootcamps`
--

DROP TABLE IF EXISTS `vwpopularbootcamps`;
/*!50001 DROP VIEW IF EXISTS `vwpopularbootcamps`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vwpopularbootcamps` AS SELECT 
 1 AS `bootcamp_id`,
 1 AS `bootcamp_title`,
 1 AS `category`,
 1 AS `level`,
 1 AS `capacity`,
 1 AS `mentor_name`,
 1 AS `enrollment_count`,
 1 AS `capacity_used_pct`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vwtopcoders`
--

DROP TABLE IF EXISTS `vwtopcoders`;
/*!50001 DROP VIEW IF EXISTS `vwtopcoders`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vwtopcoders` AS SELECT 
 1 AS `learner_id`,
 1 AS `username`,
 1 AS `email`,
 1 AS `total_skill_score`,
 1 AS `assessments_completed`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'global_bootcamp'
--

--
-- Dumping routines for database 'global_bootcamp'
--
/*!50003 DROP PROCEDURE IF EXISTS `spAddResource` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `spAddResource`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spEnrollLearner` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `spEnrollLearner`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spRegisterLearner` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `spRegisterLearner`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spRenewSubscription` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `spRenewSubscription`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spSendNotice` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `spSendNotice`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vwblockedlearners`
--

/*!50001 DROP VIEW IF EXISTS `vwblockedlearners`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vwblockedlearners` AS select `l`.`learner_id` AS `learner_id`,`l`.`username` AS `username`,`l`.`email` AS `email`,`l`.`account_status` AS `account_status`,`l`.`subscription_expiry` AS `subscription_expiry`,(to_days(curdate()) - to_days(`l`.`subscription_expiry`)) AS `days_overdue` from `learners` `l` where ((`l`.`account_status` = 'Blocked') and (`l`.`subscription_expiry` < curdate())) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vwmostdownloadedresources`
--

/*!50001 DROP VIEW IF EXISTS `vwmostdownloadedresources`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vwmostdownloadedresources` AS select `r`.`resource_id` AS `resource_id`,`r`.`title` AS `resource_title`,`r`.`resource_type` AS `resource_type`,`r`.`size_mb` AS `size_mb`,`r`.`download_count` AS `download_count`,`b`.`title` AS `bootcamp_title`,`b`.`category` AS `bootcamp_category` from (`resources` `r` join `bootcamps` `b` on((`r`.`bootcamp_id` = `b`.`bootcamp_id`))) order by `r`.`download_count` desc limit 20 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vwpopularbootcamps`
--

/*!50001 DROP VIEW IF EXISTS `vwpopularbootcamps`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vwpopularbootcamps` AS select `b`.`bootcamp_id` AS `bootcamp_id`,`b`.`title` AS `bootcamp_title`,`b`.`category` AS `category`,`b`.`level` AS `level`,`b`.`capacity` AS `capacity`,`m`.`full_name` AS `mentor_name`,count(`e`.`enrollment_id`) AS `enrollment_count`,round(((count(`e`.`enrollment_id`) / `b`.`capacity`) * 100),2) AS `capacity_used_pct` from ((`bootcamps` `b` join `mentors` `m` on((`b`.`mentor_id` = `m`.`mentor_id`))) left join `enrollments` `e` on((`b`.`bootcamp_id` = `e`.`bootcamp_id`))) group by `b`.`bootcamp_id`,`b`.`title`,`b`.`category`,`b`.`level`,`b`.`capacity`,`m`.`full_name` order by `enrollment_count` desc limit 5 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vwtopcoders`
--

/*!50001 DROP VIEW IF EXISTS `vwtopcoders`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vwtopcoders` AS select `l`.`learner_id` AS `learner_id`,`l`.`username` AS `username`,`l`.`email` AS `email`,sum(`ar`.`skill_score`) AS `total_skill_score`,count(`ar`.`result_id`) AS `assessments_completed` from (`learners` `l` join `assessment_results` `ar` on((`l`.`learner_id` = `ar`.`learner_id`))) group by `l`.`learner_id`,`l`.`username`,`l`.`email` order by `total_skill_score` desc limit 20 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-22 12:23:15
