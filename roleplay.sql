-- Listage de la structure de la table roleplay. accounts
CREATE TABLE IF NOT EXISTS `accounts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `steamid` varchar(17) NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT 'Unregistered',
  `clothing` text NOT NULL,
  `police` tinyint(1) NOT NULL DEFAULT '0',
  `medic` tinyint(1) NOT NULL DEFAULT '0',
  `inventory` text NOT NULL,
  `position` text NOT NULL,
  `admin` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `health` float NOT NULL DEFAULT '100',
  `armor` float NOT NULL DEFAULT '0',
  `thirst` float NOT NULL DEFAULT '100',
  `hunger` float NOT NULL DEFAULT '100',
  `bank_balance` int(11) NOT NULL DEFAULT '900',
  `created` tinyint(1) NOT NULL DEFAULT '0',
  `phone_number` varchar(255) DEFAULT NULL,
  `driver_license` tinyint(1) NOT NULL DEFAULT '0',
  `gun_license` tinyint(1) NOT NULL DEFAULT '0',
  `helicopter_license` tinyint(1) NOT NULL DEFAULT '0',
  `taxi_license` varchar(255) NULL DEFAULT '0',
  `drug_knowledge` text NOT NULL,
  `job` varchar(20) DEFAULT NULL,
  `is_cuffed` tinyint(1) NOT NULL DEFAULT '0',
  `age` int(11) NOT NULL DEFAULT '0',
  `is_online` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;

-- Listage de la structure de la table roleplay. bans
CREATE TABLE IF NOT EXISTS `bans` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `steamid` varchar(17) NOT NULL,
  `ban_time` int(10) unsigned NOT NULL,
  `reason` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Listage des données de la table roleplay.bans : ~0 rows (environ)
/*!40000 ALTER TABLE `bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `bans` ENABLE KEYS */;

-- Listage de la structure de la table roleplay. fines
CREATE TABLE IF NOT EXISTS `fines` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `fine_date` datetime NOT NULL,
  `agent_id` smallint(6) NOT NULL DEFAULT 0,
  `player_id` smallint(6) NOT NULL DEFAULT 0,
  `amount` int(11) NOT NULL DEFAULT 0,
  `reason` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `paid` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Listage des données de la table roleplay.fines : ~0 rows (environ)
/*!40000 ALTER TABLE `fines` DISABLE KEYS */;
/*!40000 ALTER TABLE `fines` ENABLE KEYS */;

-- Listage de la structure de la table roleplay. ipbans
CREATE TABLE IF NOT EXISTS `ipbans` (
  `ip` varchar(16) NOT NULL,
  `ban_time` int(10) unsigned NOT NULL,
  `reason` varchar(128) NOT NULL,
  PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Listage des données de la table roleplay.ipbans : ~0 rows (environ)
/*!40000 ALTER TABLE `ipbans` DISABLE KEYS */;
/*!40000 ALTER TABLE `ipbans` ENABLE KEYS */;

-- Listage de la structure de la table roleplay. items
CREATE TABLE IF NOT EXISTS `items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `subcategory` varchar(255) NOT NULL,
  `price` int(11) NOT NULL,
  `weight` int(11) NOT NULL COMMENT 'in grams',
  `hunger` int(11) NOT NULL,
  `thirst` int(11) NOT NULL,
  `equipable` tinyint(4) NOT NULL DEFAULT 0,
  `usable` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=47 DEFAULT CHARSET=latin1;

-- --------------------------------------------------------
-- Hôte :                        127.0.0.1
-- Version du serveur:           10.4.11-MariaDB - mariadb.org binary distribution
-- SE du serveur:                Win64
-- HeidiSQL Version:             10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Listage des données de la table roleplay.items : 46 rows
INSERT INTO `items` (`id`, `name`, `category`, `subcategory`, `price`, `weight`, `hunger`, `thirst`, `equipable`, `usable`) VALUES
	(NULL, 'water_bottle', 'miscellaneous', 'food', 8, 2000, 0, 30, 0, 1),
	(NULL, 'apple', 'miscellaneous', 'food', 5, 2000, 30, 0, 0, 1),
	(NULL, 'donut', 'miscellaneous', 'food', 3, 2000, 30, 0, 0, 1),
	(NULL, 'repair_kit', 'ironsmith', 'object', 300, 6000, 0, 0, 0, 1),
	(NULL, 'health_kit', 'miscellaneous', 'object', 500, 5000, 0, 0, 0, 1),
	(NULL, 'lockpick', 'ironsmith', 'object', 500, 4000, 0, 0, 0, 1),
	(NULL, 'pickaxe', 'ironsmith', 'tool', 60, 3000, 0, 0, 0, 1),
	(NULL, 'jerican', 'miscellaneous', 'object', 100, 3000, 0, 0, 0, 1),
	(NULL, 'phone', 'miscellaneous', 'object', 750, 2000, 0, 0, 0, 1),
	(NULL, 'fishing_rod', 'ironsmith', 'tool', 60, 3000, 0, 0, 0, 1),
	(NULL, 'weapon_2', 'weapons', 'weapon', 39000, 7000, 0, 0, 1, 0),
	(NULL, 'weapon_3', 'weapons', 'weapon', 45000, 6000, 0, 0, 1, 0),
	(NULL, 'weapon_4', 'weapons', 'weapon', 48000, 5000, 0, 0, 1, 0),
	(NULL, 'weapon_5', 'weapons', 'weapon', 43000, 6000, 0, 0, 1, 0),
	(NULL, 'weapon_6', 'weapons', 'weapon', 65000, 17000, 0, 0, 1, 0),
	(NULL, 'weapon_7', 'weapons', 'weapon', 66000, 17000, 0, 0, 1, 0),
	(NULL, 'weapon_8', 'weapons', 'weapon', 80000, 13000, 0, 0, 1, 0),
	(NULL, 'weapon_9', 'weapons', 'weapon', 80000, 12000, 0, 0, 1, 0),
	(NULL, 'weapon_10', 'weapons', 'weapon', 80000, 14000, 0, 0, 1, 0),
	(NULL, 'weapon_11', 'weapons', 'weapon', 185000, 16000, 0, 0, 1, 0),
	(NULL, 'weapon_12', 'weapons', 'weapon', 170000, 18000, 0, 0, 1, 0),
	(NULL, 'weapon_13', 'weapons', 'weapon', 5000000, 18000, 0, 0, 1, 0),
	(NULL, 'weapon_14', 'weapons', 'weapon', 210000, 20000, 0, 0, 1, 0),
	(NULL, 'weapon_15', 'weapons', 'weapon', 110000, 20000, 0, 0, 1, 0),
	(NULL, 'weapon_16', 'weapons', 'weapon', 180000, 18000, 0, 0, 1, 0),
	(NULL, 'weapon_17', 'weapons', 'weapon', 190000, 20000, 0, 0, 1, 0),
	(NULL, 'weapon_18', 'weapons', 'weapon', 135000, 20000, 0, 0, 1, 0),
	(NULL, 'weapon_19', 'weapons', 'weapon', 200000, 20000, 0, 0, 1, 0),
	(NULL, 'weapon_20', 'weapons', 'weapon', 5000000, 30000, 0, 0, 1, 0),
	(NULL, 'weapon_21', 'weapons', 'weapon', 5000000, 5000, 0, 0, 1, 0),
	(NULL, 'iron_pipe', 'job_item', 'object', 0, 16000, 0, 0, 0, 0),
	(NULL, 'peach', 'job_item', 'food', 0, 4000, 30, 5, 0, 1),
	(NULL, 'item_backpack', 'miscellaneous', 'object', 150, 1000, 0, 0, 1, 0),
	(NULL, 'coca_leaf', 'drugs', 'object', 450, 1000, -50, -50, 0, 1),
	(NULL, 'cocaine', 'drugs', 'food', 100, 4000, -25, -15, -20, 1),
	(NULL, 'weed', 'drugs', 'food', 50, 2000, -10, -10, 0, 1),
	(NULL, 'lumberjack_axe', 'ironsmith', 'tool', 60, 3000, 0, 0, 0, 0),
	(NULL, 'tree_log', 'job_item', 'object', 0, 12000, 0, 0, 0, 0),
	(NULL, 'wood_plank', 'job_item', 'object', 0, 6000, 0, 0, 0, 0),
	(NULL, 'iron_ingot', 'job_item', 'object', 0, 8000, 0, 0, 0, 0),
	(NULL, 'lumberjack_saw', 'ironsmith', 'tool', 60, 3000, 0, 0, 0, 0),
	(NULL, 'handcuffs', 'job_item', 'tool', 0, 1000, 0, 0, 0, 0),
	(NULL, 'iron_ore', 'job_item', 'object', 0, 16000, 0, 0, 0, 0),
	(NULL, 'defibrillator', 'job_item', 'tool', 0, 6000, 0, 0, 0, 0),
	(NULL, 'adrenaline_syringe', 'job_item', 'tool', 0, 1000, 0, 0, 0, 1),
	(NULL, 'bandage', 'job_item', 'tool', 0, 1000, 0, 0, 0, 1),
	(NULL, 'herring', 'job_item', 'food', 0, 5000, 35, 0, 0, 1),
	(NULL, 'mask_1', 'masks', 'object', 5000, 100, 0, 0, 1, 0),
	(NULL, 'mask_2', 'masks', 'object', 6000, 100, 0, 0, 1, 0),
	(NULL, 'mask_3', 'masks', 'object', 8000, 100, 0, 0, 1, 0),
	(NULL, 'mask_4', 'masks', 'object', 10000, 100, 0, 0, 1, 0);

-- Listage de la structure de la table roleplay. logs
CREATE TABLE IF NOT EXISTS `logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `action` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=latin1;

-- Listage de la structure de la table roleplay. messages
CREATE TABLE IF NOT EXISTS `messages` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `from` varchar(255) NOT NULL DEFAULT '0',
  `to` varchar(255) NOT NULL DEFAULT '0',
  `content` text NOT NULL,
  `created_at` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Listage des données de la table roleplay.messages : ~0 rows (environ)
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;

-- Listage de la structure de la table roleplay. phone_contacts
CREATE TABLE IF NOT EXISTS `phone_contacts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `owner_id` int(10) NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL DEFAULT '',
  `phone` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Listage des données de la table roleplay.phone_contacts : ~0 rows (environ)
/*!40000 ALTER TABLE `phone_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `phone_contacts` ENABLE KEYS */;

-- Listage de la structure de la table roleplay. player_garage
CREATE TABLE IF NOT EXISTS `player_garage` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ownerid` int(10) unsigned NOT NULL,
  `modelid` mediumint(8) unsigned NOT NULL,
  `color` varchar(255) NOT NULL,
  `garage` tinyint(1) NOT NULL,
  `price` int(11) NOT NULL,
  `fuel` int(11) NOT NULL DEFAULT 100,
  `health` int(11) NOT NULL DEFAULT 5000,
  `license_plate` varchar(10) NOT NULL DEFAULT "AA-111-AA",
  `inventory` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `player_vehicle_ibfk_1` (`ownerid`),
  CONSTRAINT `player_garage_ibfk_1` FOREIGN KEY (`ownerid`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Listage de la structure de la table roleplay. player_house
CREATE TABLE IF NOT EXISTS `player_house` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ownerid` int(10) unsigned NOT NULL DEFAULT 0,
  `spawn` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8;

-- Listage des données de la table roleplay.player_house : ~87 rows (environ)
/*!40000 ALTER TABLE `player_house` DISABLE KEYS */;
INSERT INTO `player_house` (`id`, `ownerid`, `spawn`) VALUES
	(1, 0, 0),
	(2, 0, 0),
	(3, 0, 0),
	(4, 0, 0),
	(5, 0, 0),
	(6, 0, 0),
	(7, 0, 0),
	(8, 0, 0),
	(9, 0, 0),
	(10, 0, 0),
	(11, 0, 0),
	(12, 0, 0),
	(13, 0, 0),
	(14, 0, 0),
	(15, 0, 0),
	(16, 0, 0),
	(17, 0, 0),
	(18, 0, 0),
	(19, 0, 0),
	(20, 0, 0),
	(21, 0, 0),
	(22, 0, 0),
	(23, 0, 0),
	(24, 0, 0),
	(25, 0, 0),
	(26, 0, 0),
	(27, 0, 0),
	(28, 0, 0),
	(29, 0, 0),
	(30, 0, 0),
	(31, 0, 0),
	(32, 0, 0),
	(33, 0, 0),
	(34, 0, 0),
	(35, 0, 0),
	(36, 0, 0),
	(37, 0, 0),
	(38, 0, 0),
	(39, 0, 0),
	(40, 0, 0),
	(41, 0, 0),
	(42, 0, 0),
	(43, 0, 0),
	(44, 0, 0),
	(45, 0, 0),
	(46, 0, 0),
	(47, 0, 0),
	(48, 0, 0),
	(49, 0, 0),
	(50, 0, 0),
	(51, 0, 0),
	(52, 0, 0),
	(53, 0, 0),
	(54, 0, 0),
	(55, 0, 0),
	(56, 0, 0),
	(57, 0, 0),
	(58, 0, 0),
	(59, 0, 0),
	(60, 0, 0),
	(61, 0, 0),
	(62, 0, 0),
	(63, 0, 0),
	(64, 0, 0),
	(65, 0, 0),
	(66, 0, 0),
	(67, 0, 0),
	(68, 0, 0),
	(69, 0, 0),
	(70, 0, 0),
	(71, 0, 0),
	(72, 0, 0),
	(73, 0, 0),
	(74, 0, 0),
	(75, 0, 0),
	(76, 0, 0),
	(77, 0, 0),
	(78, 0, 0),
	(79, 0, 0),
	(80, 0, 0),
	(81, 0, 0),
	(82, 0, 0),
	(83, 0, 0),
	(84, 0, 0),
	(85, 0, 0),
	(86, 0, 0),
	(87, 0, 0);
/*!40000 ALTER TABLE `player_house` ENABLE KEYS */;

-- Listage de la structure de la table roleplay. shops
CREATE TABLE IF NOT EXISTS `shops` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `x` int(11) NOT NULL,
  `y` int(11) NOT NULL,
  `z` int(11) NOT NULL,
  `h` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

INSERT INTO `shops` (`id`, `name`, `category`, `x`, `y`, `z`, `h`) VALUES
	(1, 'twentyfour', 'miscellaneous', 128748, 77622, 1576, 90),
	(2, 'twentyfour', 'miscellaneous', 42694, 137926, 1581, 90),
	(3, 'twentyfour', 'miscellaneous', -15402, -2773, 2065, 90),
	(4, 'twentyfour', 'miscellaneous', -169093, -39441, 1149, 90),
	(5, 'twentyfour', 'miscellaneous', 171131, 203562, 1413, -180),
	(6, 'gunshop', 'weapons', -181943, -40882, 1163, 90),
	(7, 'gunshop', 'weapons', 206071, 193057, 1357, 180),
	(9, 'ironsmith', 'ironsmith', -189805, -34122, 1148, 90),
	(10, 'ironsmith', 'ironsmith', 182971, 199704, 1315, -90),
	(11, 'masks', 'masks', 185510, 182923, 1301, -180),
	(13, 'drugdealer_name', 'drugs', 72104, -2325, 1375, 360);

-- Listage de la structure de la table roleplay. whitelist
CREATE TABLE IF NOT EXISTS `whitelist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `steamid` varchar(17) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Listage des données de la table roleplay.whitelist : ~0 rows (environ)
/*!40000 ALTER TABLE `whitelist` DISABLE KEYS */;
/*!40000 ALTER TABLE `whitelist` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
