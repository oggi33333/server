-- Civilian Jobs Database Tables
-- Run this in your MySQL database

-- Civilian job logs table
CREATE TABLE IF NOT EXISTS `civilian_job_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(60) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `job_type` varchar(50) NOT NULL,
  `activity` text NOT NULL,
  `amount` int(11) DEFAULT 0,
  `experience_gained` int(11) DEFAULT 0,
  `activity_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `location` text DEFAULT NULL,
  `coords_x` float DEFAULT NULL,
  `coords_y` float DEFAULT NULL,
  `coords_z` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`),
  KEY `job_type` (`job_type`),
  KEY `activity_time` (`activity_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Player job statistics table
CREATE TABLE IF NOT EXISTS `player_job_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(60) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `job_type` varchar(50) NOT NULL,
  `total_activities` int(11) NOT NULL DEFAULT 0,
  `total_earned` int(11) NOT NULL DEFAULT 0,
  `total_time_worked` int(11) NOT NULL DEFAULT 0,
  `experience_points` int(11) NOT NULL DEFAULT 0,
  `current_level` int(11) NOT NULL DEFAULT 1,
  `best_single_earning` int(11) NOT NULL DEFAULT 0,
  `last_activity` timestamp NULL DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `player_job` (`player_id`, `job_type`),
  KEY `player_id` (`player_id`),
  KEY `job_type` (`job_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Daily job bonuses table
CREATE TABLE IF NOT EXISTS `daily_job_bonuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(60) NOT NULL,
  `bonus_date` date NOT NULL,
  `bonus_type` enum('daily','weekly','monthly','random') NOT NULL,
  `amount` int(11) NOT NULL,
  `claimed_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `player_bonus_date` (`player_id`, `bonus_date`, `bonus_type`),
  KEY `player_id` (`player_id`),
  KEY `bonus_date` (`bonus_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Fishing catches table
CREATE TABLE IF NOT EXISTS `fishing_catches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(60) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `fish_type` varchar(50) NOT NULL,
  `fish_size` varchar(20) DEFAULT 'normal',
  `sell_price` int(11) NOT NULL,
  `fishing_spot` varchar(100) NOT NULL,
  `catch_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `coords_x` float DEFAULT NULL,
  `coords_y` float DEFAULT NULL,
  `coords_z` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`),
  KEY `fish_type` (`fish_type`),
  KEY `catch_time` (`catch_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Delivery routes table
CREATE TABLE IF NOT EXISTS `delivery_routes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(60) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `route_start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `route_end_time` timestamp NULL DEFAULT NULL,
  `total_deliveries` int(11) NOT NULL DEFAULT 0,
  `deliveries_completed` int(11) NOT NULL DEFAULT 0,
  `total_earnings` int(11) NOT NULL DEFAULT 0,
  `route_status` enum('active','completed','abandoned') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`),
  KEY `route_start_time` (`route_start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Garbage routes table
CREATE TABLE IF NOT EXISTS `garbage_routes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(60) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `route_start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `route_end_time` timestamp NULL DEFAULT NULL,
  `total_containers` int(11) NOT NULL DEFAULT 0,
  `containers_collected` int(11) NOT NULL DEFAULT 0,
  `total_earnings` int(11) NOT NULL DEFAULT 0,
  `route_status` enum('active','completed','abandoned') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`),
  KEY `route_start_time` (`route_start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Construction work sessions table
CREATE TABLE IF NOT EXISTS `construction_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(60) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `site_name` varchar(100) NOT NULL,
  `session_start` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `session_end` timestamp NULL DEFAULT NULL,
  `work_completed` int(11) NOT NULL DEFAULT 0,
  `total_earnings` int(11) NOT NULL DEFAULT 0,
  `coords_x` float DEFAULT NULL,
  `coords_y` float DEFAULT NULL,
  `coords_z` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`),
  KEY `site_name` (`site_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Clothing store sales table
CREATE TABLE IF NOT EXISTS `clothing_sales` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller_id` varchar(60) NOT NULL,
  `seller_name` varchar(100) NOT NULL,
  `buyer_id` varchar(60) DEFAULT NULL,
  `buyer_name` varchar(100) DEFAULT NULL,
  `item_name` varchar(100) NOT NULL,
  `sale_price` int(11) NOT NULL,
  `commission` int(11) NOT NULL,
  `store_name` varchar(100) NOT NULL,
  `sale_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `seller_id` (`seller_id`),
  KEY `buyer_id` (`buyer_id`),
  KEY `sale_time` (`sale_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Taxi rides table
CREATE TABLE IF NOT EXISTS `taxi_rides` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `driver_id` varchar(60) NOT NULL,
  `driver_name` varchar(100) NOT NULL,
  `passenger_id` varchar(60) DEFAULT NULL,
  `passenger_name` varchar(100) DEFAULT NULL,
  `pickup_location` text DEFAULT NULL,
  `dropoff_location` text DEFAULT NULL,
  `distance` float DEFAULT NULL,
  `fare_amount` int(11) NOT NULL,
  `tip_amount` int(11) DEFAULT 0,
  `total_amount` int(11) NOT NULL,
  `ride_start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ride_end_time` timestamp NULL DEFAULT NULL,
  `ride_duration` int(11) DEFAULT NULL,
  `passenger_rating` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `driver_id` (`driver_id`),
  KEY `passenger_id` (`passenger_id`),
  KEY `ride_start_time` (`ride_start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Player achievements table
CREATE TABLE IF NOT EXISTS `player_achievements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(60) NOT NULL,
  `achievement_name` varchar(100) NOT NULL,
  `achievement_description` text DEFAULT NULL,
  `category` varchar(50) NOT NULL,
  `points_awarded` int(11) DEFAULT 0,
  `unlocked_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `player_achievement` (`player_id`, `achievement_name`),
  KEY `player_id` (`player_id`),
  KEY `category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Job leaderboards view
CREATE OR REPLACE VIEW `job_leaderboards` AS
SELECT 
    job_type,
    player_name,
    total_earned,
    total_activities,
    current_level,
    RANK() OVER (PARTITION BY job_type ORDER BY total_earned DESC) as earnings_rank,
    RANK() OVER (PARTITION BY job_type ORDER BY total_activities DESC) as activity_rank,
    RANK() OVER (PARTITION BY job_type ORDER BY current_level DESC, experience_points DESC) as level_rank
FROM player_job_stats
ORDER BY job_type, total_earned DESC;

-- Add civilian jobs to jobs table (if not exists)
INSERT IGNORE INTO `jobs` (`name`, `label`) VALUES
('unemployed', 'Arbeitslos'),
('garbage', 'Müllmann'),
('fisherman', 'Fischer'),
('delivery', 'Lieferfahrer'),
('construction', 'Bauarbeiter'),
('clothing', 'Kleidungsverkäufer'),
('taxi', 'Taxi Fahrer');

-- Add job grades for civilian jobs
INSERT IGNORE INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('unemployed', 0, 'unemployed', 'Arbeitslos', 0, '{}', '{}'),
('garbage', 0, 'employee', 'Angestellter', 250, '{}', '{}'),
('garbage', 1, 'experienced', 'Erfahren', 300, '{}', '{}'),
('garbage', 2, 'supervisor', 'Vorarbeiter', 400, '{}', '{}'),
('fisherman', 0, 'novice', 'Anfänger', 200, '{}', '{}'),
('fisherman', 1, 'experienced', 'Erfahren', 250, '{}', '{}'),
('fisherman', 2, 'expert', 'Experte', 350, '{}', '{}'),
('delivery', 0, 'driver', 'Fahrer', 300, '{}', '{}'),
('delivery', 1, 'experienced', 'Erfahren', 350, '{}', '{}'),
('delivery', 2, 'supervisor', 'Vorarbeiter', 450, '{}', '{}'),
('construction', 0, 'worker', 'Arbeiter', 350, '{}', '{}'),
('construction', 1, 'experienced', 'Erfahren', 400, '{}', '{}'),
('construction', 2, 'foreman', 'Vorarbeiter', 500, '{}', '{}'),
('clothing', 0, 'sales', 'Verkäufer', 250, '{}', '{}'),
('clothing', 1, 'experienced', 'Erfahren', 300, '{}', '{}'),
('clothing', 2, 'manager', 'Manager', 450, '{}', '{}'),
('taxi', 0, 'driver', 'Fahrer', 200, '{}', '{}'),
('taxi', 1, 'experienced', 'Erfahren', 250, '{}', '{}'),
('taxi', 2, 'supervisor', 'Vorarbeiter', 350, '{}', '{}');

-- Add items to items table (if using ox_inventory or similar)
-- INSERT IGNORE INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
-- ('fishing_rod', 'Angelrute', 2000, 0, 1),
-- ('fish_sardine', 'Sardine', 300, 0, 1),
-- ('fish_trout', 'Forelle', 800, 0, 1),
-- ('fish_salmon', 'Lachs', 1200, 0, 1),
-- ('fish_tuna', 'Thunfisch', 2000, 0, 1),
-- ('fish_shark', 'Hai', 5000, 1, 1);

-- Insert some sample achievements
INSERT IGNORE INTO `player_achievements` (`player_id`, `achievement_name`, `achievement_description`, `category`, `points_awarded`) VALUES
('sample', 'First Catch', 'Fange deinen ersten Fisch', 'fishing', 10),
('sample', 'Garbage Hero', 'Sammle 100 Müllcontainer', 'garbage', 25),
('sample', 'Delivery Master', 'Schließe 50 Lieferungen ab', 'delivery', 30),
('sample', 'Construction King', 'Arbeite 10 Stunden auf Baustellen', 'construction', 40),
('sample', 'Fashion Expert', 'Verkaufe Kleidung im Wert von $10,000', 'clothing', 35),
('sample', 'Taxi Legend', 'Fahre 1000km als Taxi Fahrer', 'taxi', 50);

-- Create indexes for better performance
CREATE INDEX idx_civilian_logs_player_job ON civilian_job_logs(player_id, job_type);
CREATE INDEX idx_civilian_logs_time ON civilian_job_logs(activity_time);
CREATE INDEX idx_player_stats_earnings ON player_job_stats(total_earned DESC);
CREATE INDEX idx_fishing_player_time ON fishing_catches(player_id, catch_time);
CREATE INDEX idx_achievements_player ON player_achievements(player_id);