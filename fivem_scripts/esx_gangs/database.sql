-- Gang System Database Tables
-- Run this in your MySQL database

-- Gangs table
CREATE TABLE IF NOT EXISTS `gangs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL UNIQUE,
  `label` varchar(100) NOT NULL,
  `bank_money` int(11) NOT NULL DEFAULT 0,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `leader_id` varchar(60) DEFAULT NULL,
  `leader_name` varchar(100) DEFAULT NULL,
  `status` enum('active','inactive','disbanded') NOT NULL DEFAULT 'active',
  `total_members` int(11) NOT NULL DEFAULT 0,
  `total_territories` int(11) NOT NULL DEFAULT 0,
  `total_wars` int(11) NOT NULL DEFAULT 0,
  `wins` int(11) NOT NULL DEFAULT 0,
  `losses` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Gang members table
CREATE TABLE IF NOT EXISTS `gang_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(60) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `gang_name` varchar(50) NOT NULL,
  `rank` int(11) NOT NULL DEFAULT 1,
  `joined_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_active` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `experience` int(11) NOT NULL DEFAULT 0,
  `kills` int(11) NOT NULL DEFAULT 0,
  `deaths` int(11) NOT NULL DEFAULT 0,
  `drug_sales` int(11) NOT NULL DEFAULT 0,
  `territories_captured` int(11) NOT NULL DEFAULT 0,
  `total_earnings` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `player_gang` (`player_id`),
  KEY `gang_name` (`gang_name`),
  FOREIGN KEY (`gang_name`) REFERENCES `gangs`(`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Gang territories table
CREATE TABLE IF NOT EXISTS `gang_territories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `coords_x` float NOT NULL,
  `coords_y` float NOT NULL,
  `coords_z` float NOT NULL,
  `radius` float NOT NULL DEFAULT 100.0,
  `owner_gang` varchar(50) DEFAULT NULL,
  `captured_date` timestamp NULL DEFAULT NULL,
  `income` int(11) NOT NULL DEFAULT 0,
  `status` enum('peaceful','contested','war') NOT NULL DEFAULT 'peaceful',
  `last_attack` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `owner_gang` (`owner_gang`),
  FOREIGN KEY (`owner_gang`) REFERENCES `gangs`(`name`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Gang wars table
CREATE TABLE IF NOT EXISTS `gang_wars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `territory_id` int(11) DEFAULT NULL,
  `attacking_gang` varchar(50) NOT NULL,
  `defending_gang` varchar(50) DEFAULT NULL,
  `war_type` enum('territory','gang_war','turf') NOT NULL DEFAULT 'territory',
  `war_start` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `war_end` timestamp NULL DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `status` enum('active','won','lost','draw') NOT NULL DEFAULT 'active',
  `winner_gang` varchar(50) DEFAULT NULL,
  `loser_gang` varchar(50) DEFAULT NULL,
  `attacking_members` int(11) NOT NULL DEFAULT 0,
  `defending_members` int(11) NOT NULL DEFAULT 0,
  `total_kills` int(11) NOT NULL DEFAULT 0,
  `war_reason` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `territory_id` (`territory_id`),
  KEY `attacking_gang` (`attacking_gang`),
  KEY `defending_gang` (`defending_gang`),
  FOREIGN KEY (`territory_id`) REFERENCES `gang_territories`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`attacking_gang`) REFERENCES `gangs`(`name`) ON DELETE CASCADE,
  FOREIGN KEY (`defending_gang`) REFERENCES `gangs`(`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Gang activities table
CREATE TABLE IF NOT EXISTS `gang_activities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gang_name` varchar(50) NOT NULL,
  `player_id` varchar(60) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `activity_type` enum('drug_sale','weapon_purchase','territory_capture','gang_war','bank_deposit','bank_withdraw','member_invite','member_kick','rank_change') NOT NULL,
  `amount` int(11) DEFAULT NULL,
  `target_player` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `activity_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `coords_x` float DEFAULT NULL,
  `coords_y` float DEFAULT NULL,
  `coords_z` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `gang_name` (`gang_name`),
  KEY `player_id` (`player_id`),
  KEY `activity_type` (`activity_type`),
  FOREIGN KEY (`gang_name`) REFERENCES `gangs`(`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Gang vehicles table
CREATE TABLE IF NOT EXISTS `gang_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gang_name` varchar(50) NOT NULL,
  `owner_id` varchar(60) NOT NULL,
  `vehicle_model` varchar(50) NOT NULL,
  `vehicle_plate` varchar(10) NOT NULL,
  `spawn_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `despawn_time` timestamp NULL DEFAULT NULL,
  `location` text DEFAULT NULL,
  `status` enum('active','stored','destroyed','impounded') NOT NULL DEFAULT 'active',
  `upgrades` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vehicle_plate` (`vehicle_plate`),
  KEY `gang_name` (`gang_name`),
  KEY `owner_id` (`owner_id`),
  FOREIGN KEY (`gang_name`) REFERENCES `gangs`(`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Gang bank transactions table
CREATE TABLE IF NOT EXISTS `gang_bank_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gang_name` varchar(50) NOT NULL,
  `player_id` varchar(60) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `transaction_type` enum('deposit','withdraw','salary','income','fine','reward') NOT NULL,
  `amount` int(11) NOT NULL,
  `balance_before` int(11) NOT NULL,
  `balance_after` int(11) NOT NULL,
  `description` text DEFAULT NULL,
  `transaction_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `gang_name` (`gang_name`),
  KEY `player_id` (`player_id`),
  FOREIGN KEY (`gang_name`) REFERENCES `gangs`(`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Gang drug operations table
CREATE TABLE IF NOT EXISTS `gang_drug_operations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gang_name` varchar(50) NOT NULL,
  `player_id` varchar(60) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `operation_type` enum('purchase','sale','transport','production') NOT NULL,
  `drug_type` varchar(50) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price_per_unit` int(11) NOT NULL,
  `total_amount` int(11) NOT NULL,
  `location` text DEFAULT NULL,
  `coords_x` float DEFAULT NULL,
  `coords_y` float DEFAULT NULL,
  `coords_z` float DEFAULT NULL,
  `operation_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `success` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `gang_name` (`gang_name`),
  KEY `player_id` (`player_id`),
  FOREIGN KEY (`gang_name`) REFERENCES `gangs`(`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Gang weapon transactions table
CREATE TABLE IF NOT EXISTS `gang_weapon_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gang_name` varchar(50) NOT NULL,
  `player_id` varchar(60) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `transaction_type` enum('purchase','sale','upgrade','confiscated') NOT NULL,
  `weapon_type` varchar(50) NOT NULL,
  `weapon_hash` varchar(50) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `price` int(11) NOT NULL,
  `ammo_amount` int(11) DEFAULT NULL,
  `transaction_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `gang_name` (`gang_name`),
  KEY `player_id` (`player_id`),
  FOREIGN KEY (`gang_name`) REFERENCES `gangs`(`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Gang alliances table
CREATE TABLE IF NOT EXISTS `gang_alliances` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gang1` varchar(50) NOT NULL,
  `gang2` varchar(50) NOT NULL,
  `alliance_type` enum('alliance','truce','war','neutral') NOT NULL DEFAULT 'neutral',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `end_date` timestamp NULL DEFAULT NULL,
  `created_by` varchar(60) NOT NULL,
  `status` enum('active','expired','broken') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`id`),
  UNIQUE KEY `gang_pair` (`gang1`, `gang2`),
  FOREIGN KEY (`gang1`) REFERENCES `gangs`(`name`) ON DELETE CASCADE,
  FOREIGN KEY (`gang2`) REFERENCES `gangs`(`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default gangs
INSERT IGNORE INTO `gangs` (`name`, `label`, `bank_money`, `leader_id`, `status`) VALUES
('vagos', 'Los Santos Vagos', 50000, NULL, 'active'),
('ballas', 'Ballas', 50000, NULL, 'active'),
('families', 'Grove Street Families', 50000, NULL, 'active'),
('marabunta', 'Marabunta Grande', 50000, NULL, 'active'),
('triads', 'Triads', 50000, NULL, 'active');

-- Insert default territories
INSERT IGNORE INTO `gang_territories` (`id`, `name`, `coords_x`, `coords_y`, `coords_z`, `radius`, `owner_gang`, `income`) VALUES
(1, 'Davis', 95.2, -1909.8, 21.0, 200.0, NULL, 500),
(2, 'Groove Street', 116.1, -1961.5, 21.3, 150.0, 'families', 750),
(3, 'El Rancho', 1437.6, -1492.9, 63.6, 180.0, 'marabunta', 600),
(4, 'Little Seoul', -938.7, -29.5, 39.1, 220.0, 'triads', 800),
(5, 'Rancho', 331.3, -2039.9, 20.9, 160.0, 'vagos', 650),
(6, 'Chamberlain Hills', 114.9, -1961.5, 21.3, 170.0, 'ballas', 700),
(7, 'Strawberry', 349.9, -1804.5, 31.3, 190.0, NULL, 550),
(8, 'Mirror Park', 1151.3, -314.0, 69.2, 200.0, NULL, 900);

-- Add gang job to jobs table (if using job system integration)
-- INSERT IGNORE INTO `jobs` (`name`, `label`) VALUES
-- ('gang_vagos', 'Los Santos Vagos'),
-- ('gang_ballas', 'Ballas'),
-- ('gang_families', 'Grove Street Families'),
-- ('gang_marabunta', 'Marabunta Grande'),
-- ('gang_triads', 'Triads');

-- Add drug items to items table (if using ox_inventory or similar)
-- INSERT IGNORE INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
-- ('marijuana', 'Marihuana', 1, 0, 1),
-- ('cocaine', 'Kokain', 1, 1, 1),
-- ('meth', 'Methamphetamin', 1, 1, 1),
-- ('opium', 'Opium', 1, 1, 1);