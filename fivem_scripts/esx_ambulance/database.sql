-- Ambulance Job Database Tables
-- Run this in your MySQL database

-- Ambulance treatments table
CREATE TABLE IF NOT EXISTS `ambulance_treatments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `medic_id` varchar(60) NOT NULL,
  `medic_name` varchar(100) NOT NULL DEFAULT '',
  `patient_id` varchar(60) NOT NULL,
  `patient_name` varchar(100) NOT NULL DEFAULT '',
  `treatment_type` enum('heal','revive','transport','examine') NOT NULL,
  `treatment_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `location` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `medic_id` (`medic_id`),
  KEY `patient_id` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ambulance bills table
CREATE TABLE IF NOT EXISTS `ambulance_bills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `medic_id` varchar(60) NOT NULL,
  `medic_name` varchar(100) NOT NULL DEFAULT '',
  `patient_id` varchar(60) NOT NULL,
  `patient_name` varchar(100) NOT NULL DEFAULT '',
  `amount` int(11) NOT NULL,
  `reason` text NOT NULL,
  `bill_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `paid` tinyint(1) NOT NULL DEFAULT 0,
  `paid_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `medic_id` (`medic_id`),
  KEY `patient_id` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ambulance items given table
CREATE TABLE IF NOT EXISTS `ambulance_items_given` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `medic_id` varchar(60) NOT NULL,
  `medic_name` varchar(100) NOT NULL DEFAULT '',
  `patient_id` varchar(60) NOT NULL,
  `patient_name` varchar(100) NOT NULL DEFAULT '',
  `item_name` varchar(100) NOT NULL,
  `item_label` varchar(100) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `given_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `medic_id` (`medic_id`),
  KEY `patient_id` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ambulance vehicles table
CREATE TABLE IF NOT EXISTS `ambulance_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `medic_id` varchar(60) NOT NULL,
  `vehicle_model` varchar(50) NOT NULL,
  `vehicle_plate` varchar(10) NOT NULL,
  `spawn_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `location` text DEFAULT NULL,
  `status` enum('active','returned','destroyed') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`id`),
  KEY `medic_id` (`medic_id`),
  UNIQUE KEY `vehicle_plate` (`vehicle_plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ambulance duty log table
CREATE TABLE IF NOT EXISTS `ambulance_duty_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `medic_id` varchar(60) NOT NULL,
  `medic_name` varchar(100) NOT NULL DEFAULT '',
  `duty_start` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `duty_end` timestamp NULL DEFAULT NULL,
  `total_time` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `medic_id` (`medic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ambulance deaths table
CREATE TABLE IF NOT EXISTS `ambulance_deaths` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(60) NOT NULL,
  `player_name` varchar(100) NOT NULL DEFAULT '',
  `death_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `revive_time` timestamp NULL DEFAULT NULL,
  `revived_by` varchar(60) DEFAULT NULL,
  `revived_by_name` varchar(100) DEFAULT NULL,
  `location` text DEFAULT NULL,
  `coords_x` float DEFAULT NULL,
  `coords_y` float DEFAULT NULL,
  `coords_z` float DEFAULT NULL,
  `cause_of_death` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ambulance transports table
CREATE TABLE IF NOT EXISTS `ambulance_transports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `medic_id` varchar(60) NOT NULL,
  `medic_name` varchar(100) NOT NULL DEFAULT '',
  `patient_id` varchar(60) NOT NULL,
  `patient_name` varchar(100) NOT NULL DEFAULT '',
  `transport_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pickup_location` text DEFAULT NULL,
  `destination` varchar(200) NOT NULL,
  `transport_reason` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `medic_id` (`medic_id`),
  KEY `patient_id` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ambulance backup requests table
CREATE TABLE IF NOT EXISTS `ambulance_backup` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `medic_id` varchar(60) NOT NULL,
  `medic_name` varchar(100) NOT NULL DEFAULT '',
  `location` text NOT NULL,
  `street_name` varchar(200) DEFAULT NULL,
  `coords_x` float DEFAULT NULL,
  `coords_y` float DEFAULT NULL,
  `coords_z` float DEFAULT NULL,
  `request_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `responded_by` varchar(60) DEFAULT NULL,
  `response_time` timestamp NULL DEFAULT NULL,
  `status` enum('pending','responded','closed') NOT NULL DEFAULT 'pending',
  PRIMARY KEY (`id`),
  KEY `medic_id` (`medic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ambulance emergency calls table
CREATE TABLE IF NOT EXISTS `ambulance_emergency_calls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `caller_id` varchar(60) NOT NULL,
  `caller_name` varchar(100) NOT NULL DEFAULT '',
  `message` text NOT NULL,
  `location` text DEFAULT NULL,
  `coords_x` float DEFAULT NULL,
  `coords_y` float DEFAULT NULL,
  `coords_z` float DEFAULT NULL,
  `call_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `responded_by` varchar(60) DEFAULT NULL,
  `response_time` timestamp NULL DEFAULT NULL,
  `status` enum('pending','in_progress','completed','cancelled') NOT NULL DEFAULT 'pending',
  PRIMARY KEY (`id`),
  KEY `caller_id` (`caller_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ambulance statistics table
CREATE TABLE IF NOT EXISTS `ambulance_statistics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `medic_id` varchar(60) NOT NULL,
  `medic_name` varchar(100) NOT NULL DEFAULT '',
  `total_heals` int(11) NOT NULL DEFAULT 0,
  `total_revives` int(11) NOT NULL DEFAULT 0,
  `total_transports` int(11) NOT NULL DEFAULT 0,
  `total_duty_time` int(11) NOT NULL DEFAULT 0,
  `total_earnings` int(11) NOT NULL DEFAULT 0,
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `medic_id` (`medic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add ambulance job to jobs table (if not exists)
INSERT IGNORE INTO `jobs` (`name`, `label`) VALUES
('ambulance', 'Ambulance');

-- Add ambulance job grades
INSERT IGNORE INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('ambulance', 0, 'trainee', 'Praktikant', 200, '{}', '{}'),
('ambulance', 1, 'paramedic', 'Sanitäter', 300, '{}', '{}'),
('ambulance', 2, 'senior_paramedic', 'Oberarzt', 400, '{}', '{}'),
('ambulance', 3, 'nurse', 'Krankenschwester', 350, '{}', '{}'),
('ambulance', 4, 'doctor', 'Arzt', 500, '{}', '{}'),
('ambulance', 5, 'surgeon', 'Chirurg', 650, '{}', '{}'),
('ambulance', 6, 'chief_surgeon', 'Chefarzt', 800, '{}', '{}'),
('ambulance', 7, 'chief_medical_officer', 'Ärztlicher Direktor', 1000, '{}', '{}');

-- Add medical items to items table (if using ox_inventory or similar)
-- INSERT IGNORE INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
-- ('bandage', 'Verband', 1, 0, 1),
-- ('medikit', 'Medikit', 2, 0, 1),
-- ('painkillers', 'Schmerzmittel', 1, 0, 1),
-- ('morphine', 'Morphin', 1, 1, 1);