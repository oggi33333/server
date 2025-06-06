-- Police Job Database Tables
-- Run this in your MySQL database

-- Police arrests table
CREATE TABLE IF NOT EXISTS `police_arrests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `officer_id` varchar(60) NOT NULL,
  `officer_name` varchar(100) NOT NULL DEFAULT '',
  `suspect_id` varchar(60) NOT NULL,
  `suspect_name` varchar(100) NOT NULL DEFAULT '',
  `arrest_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `release_time` timestamp NULL DEFAULT NULL,
  `jail_time` int(11) NOT NULL DEFAULT 300,
  `reason` text DEFAULT NULL,
  `status` enum('jailed','released','escaped') NOT NULL DEFAULT 'jailed',
  PRIMARY KEY (`id`),
  KEY `officer_id` (`officer_id`),
  KEY `suspect_id` (`suspect_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Police fines table
CREATE TABLE IF NOT EXISTS `police_fines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `officer_id` varchar(60) NOT NULL,
  `officer_name` varchar(100) NOT NULL DEFAULT '',
  `suspect_id` varchar(60) NOT NULL,
  `suspect_name` varchar(100) NOT NULL DEFAULT '',
  `amount` int(11) NOT NULL,
  `reason` text NOT NULL,
  `fine_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `paid` tinyint(1) NOT NULL DEFAULT 0,
  `paid_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `officer_id` (`officer_id`),
  KEY `suspect_id` (`suspect_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Police evidence table
CREATE TABLE IF NOT EXISTS `police_evidence` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `officer_id` varchar(60) NOT NULL,
  `officer_name` varchar(100) NOT NULL DEFAULT '',
  `suspect_id` varchar(60) NOT NULL,
  `suspect_name` varchar(100) NOT NULL DEFAULT '',
  `item_name` varchar(100) NOT NULL,
  `item_label` varchar(100) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `confiscated_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `returned` tinyint(1) NOT NULL DEFAULT 0,
  `returned_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `officer_id` (`officer_id`),
  KEY `suspect_id` (`suspect_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Police vehicles table
CREATE TABLE IF NOT EXISTS `police_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `officer_id` varchar(60) NOT NULL,
  `vehicle_model` varchar(50) NOT NULL,
  `vehicle_plate` varchar(10) NOT NULL,
  `spawn_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `location` text DEFAULT NULL,
  `status` enum('active','returned','destroyed') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`id`),
  KEY `officer_id` (`officer_id`),
  UNIQUE KEY `vehicle_plate` (`vehicle_plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Police duty log table
CREATE TABLE IF NOT EXISTS `police_duty_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `officer_id` varchar(60) NOT NULL,
  `officer_name` varchar(100) NOT NULL DEFAULT '',
  `duty_start` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `duty_end` timestamp NULL DEFAULT NULL,
  `total_time` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `officer_id` (`officer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Police announcements table
CREATE TABLE IF NOT EXISTS `police_announcements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `officer_id` varchar(60) NOT NULL,
  `officer_name` varchar(100) NOT NULL DEFAULT '',
  `message` text NOT NULL,
  `announcement_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `officer_id` (`officer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Police backup requests table
CREATE TABLE IF NOT EXISTS `police_backup` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `officer_id` varchar(60) NOT NULL,
  `officer_name` varchar(100) NOT NULL DEFAULT '',
  `location` text NOT NULL,
  `street_name` varchar(200) DEFAULT NULL,
  `coords_x` float DEFAULT NULL,
  `coords_y` float DEFAULT NULL,
  `coords_z` float DEFAULT NULL,
  `request_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','responded','closed') NOT NULL DEFAULT 'pending',
  PRIMARY KEY (`id`),
  KEY `officer_id` (`officer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Update existing users table for police job (if needed)
-- This assumes you're using the standard ESX users table structure
-- ALTER TABLE `users` ADD COLUMN `police_grade` int(11) DEFAULT 0;
-- ALTER TABLE `users` ADD COLUMN `police_whitelisted` tinyint(1) DEFAULT 0;

-- Police job grades (add to jobs table if not exists)
INSERT IGNORE INTO `jobs` (`name`, `label`) VALUES
('police', 'Police');

INSERT IGNORE INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('police', 0, 'recruit', 'Rekrut', 250, '{}', '{}'),
('police', 1, 'officer', 'Beamter', 350, '{}', '{}'),
('police', 2, 'sergeant', 'Sergeant', 450, '{}', '{}'),
('police', 3, 'lieutenant', 'Leutnant', 550, '{}', '{}'),
('police', 4, 'captain', 'Hauptmann', 650, '{}', '{}'),
('police', 5, 'commander', 'Kommandant', 750, '{}', '{}'),
('police', 6, 'deputy_chief', 'Stellv. Chef', 850, '{}', '{}'),
('police', 7, 'chief', 'Polizeichef', 1000, '{}', '{}');