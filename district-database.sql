-- --------------------------------------------------------
-- Host:                         sql.23.svpj.link
-- Wersja serwera:               10.5.26-MariaDB-0+deb11u2 - Debian 11
-- Serwer OS:                    debian-linux-gnu
-- HeidiSQL Wersja:              12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Zrzut struktury tabela db_107401.m-achievements
CREATE TABLE IF NOT EXISTS `m-achievements` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` bigint(20) NOT NULL DEFAULT 0,
  `achievement` int(11) NOT NULL DEFAULT 0,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`uid`),
  KEY `Indeks 2` (`achievement`)
) ENGINE=InnoDB AUTO_INCREMENT=4599 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-achievements-count
CREATE TABLE IF NOT EXISTS `m-achievements-count` (
  `uid` bigint(20) NOT NULL,
  `achieved` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-admins
CREATE TABLE IF NOT EXISTS `m-admins` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `username` text NOT NULL,
  `serial` text NOT NULL,
  `playerUid` bigint(20) NOT NULL DEFAULT 0,
  `added` datetime NOT NULL DEFAULT current_timestamp(),
  `rank` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=173 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-daily-rewards-history
CREATE TABLE IF NOT EXISTS `m-daily-rewards-history` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` bigint(20) NOT NULL,
  `reward` text NOT NULL,
  `date` datetime NOT NULL,
  PRIMARY KEY (`uid`),
  KEY `data` (`date`,`user`)
) ENGINE=InnoDB AUTO_INCREMENT=2489 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-daily-tasks
CREATE TABLE IF NOT EXISTS `m-daily-tasks` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL DEFAULT current_timestamp(),
  `task` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `date` (`date`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-daily-tasks-history
CREATE TABLE IF NOT EXISTS `m-daily-tasks-history` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` bigint(20) NOT NULL DEFAULT 0,
  `date` date NOT NULL,
  `task` int(11) NOT NULL DEFAULT 0,
  `progress` int(11) NOT NULL DEFAULT 0,
  `claimed` tinyint(4) DEFAULT 0,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `duplication` (`date`,`user`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=52805 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-discord-notifications
CREATE TABLE IF NOT EXISTS `m-discord-notifications` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` text NOT NULL,
  `type` text NOT NULL,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`uid`),
  KEY `Indeks 2` (`user`(100),`type`(100))
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-discord-settings
CREATE TABLE IF NOT EXISTS `m-discord-settings` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` text NOT NULL,
  `setting` tinytext NOT NULL,
  `value` tinytext NOT NULL,
  `lastChanged` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`uid`),
  KEY `Indeks 2` (`user`(100),`setting`(100))
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-factions-members
CREATE TABLE IF NOT EXISTS `m-factions-members` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` bigint(20) DEFAULT NULL,
  `faction` text DEFAULT NULL,
  `rank` bigint(20) DEFAULT NULL,
  `added` datetime DEFAULT current_timestamp(),
  `addedBy` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`uid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-factions-ranks
CREATE TABLE IF NOT EXISTS `m-factions-ranks` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `faction` text DEFAULT NULL,
  `name` text DEFAULT NULL,
  `permissions` text DEFAULT NULL,
  `added` datetime DEFAULT current_timestamp(),
  `addedBy` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-furniture
CREATE TABLE IF NOT EXISTS `m-furniture` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `houseId` bigint(20) NOT NULL DEFAULT 0,
  `owner` bigint(20) DEFAULT NULL,
  `model` tinytext NOT NULL,
  `item` text DEFAULT NULL,
  `texture` tinyint(4) DEFAULT NULL,
  `position` text NOT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=780 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-house-textures
CREATE TABLE IF NOT EXISTS `m-house-textures` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `houseId` bigint(20) DEFAULT NULL,
  `textureId` bigint(20) DEFAULT NULL,
  `texture` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `house and texture` (`houseId`,`textureId`)
) ENGINE=InnoDB AUTO_INCREMENT=722 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-houses
CREATE TABLE IF NOT EXISTS `m-houses` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` text NOT NULL,
  `position` text NOT NULL,
  `interior` text NOT NULL,
  `price` int(11) NOT NULL DEFAULT 500,
  `owner` bigint(20) DEFAULT NULL,
  `sharedPlayers` tinytext NOT NULL DEFAULT '',
  `streetNumber` int(11) NOT NULL DEFAULT 0,
  `locked` tinyint(4) NOT NULL DEFAULT 0,
  `furnitured` tinyint(4) NOT NULL DEFAULT 0,
  `rentDate` datetime NOT NULL DEFAULT '1970-01-01 00:00:00',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=256 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-jobs-data
CREATE TABLE IF NOT EXISTS `m-jobs-data` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` bigint(20) NOT NULL DEFAULT 0,
  `job` tinytext NOT NULL,
  `upgradePoints` int(11) NOT NULL DEFAULT 0,
  `points` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `Indeks 3` (`user`,`job`(100)),
  KEY `points` (`job`(100),`points`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=609036 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-jobs-money-history
CREATE TABLE IF NOT EXISTS `m-jobs-money-history` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` bigint(20) NOT NULL DEFAULT 0,
  `job` text NOT NULL,
  `date` date NOT NULL DEFAULT current_timestamp(),
  `money` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `Indeks 2` (`date`,`job`(100),`user`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=727892 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-jobs-upgrades
CREATE TABLE IF NOT EXISTS `m-jobs-upgrades` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` bigint(20) NOT NULL DEFAULT 0,
  `job` tinytext NOT NULL,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  `upgrade` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`uid`),
  KEY `job` (`date`,`job`(100)) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=941 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-miner-job
CREATE TABLE IF NOT EXISTS `m-miner-job` (
  `coal` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-money-logs
CREATE TABLE IF NOT EXISTS `m-money-logs` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `player` bigint(20) NOT NULL DEFAULT 0,
  `type` text NOT NULL,
  `details` text NOT NULL,
  `money` int(11) NOT NULL DEFAULT 0,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`uid`),
  KEY `date order` (`date`)
) ENGINE=InnoDB AUTO_INCREMENT=53147 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-organizations
CREATE TABLE IF NOT EXISTS `m-organizations` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `owner` bigint(20) DEFAULT NULL,
  `name` text DEFAULT NULL,
  `tag` text DEFAULT NULL,
  `color` text DEFAULT NULL,
  `money` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`uid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-organizations-members
CREATE TABLE IF NOT EXISTS `m-organizations-members` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` bigint(20) DEFAULT NULL,
  `organization` bigint(20) DEFAULT NULL,
  `rank` bigint(20) DEFAULT NULL,
  `added` datetime DEFAULT current_timestamp(),
  `addedBy` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`uid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-organizations-money-history
CREATE TABLE IF NOT EXISTS `m-organizations-money-history` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `organization` bigint(20) NOT NULL DEFAULT 0,
  `user` bigint(20) NOT NULL,
  `amount` int(11) NOT NULL DEFAULT 0,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-organizations-ranks
CREATE TABLE IF NOT EXISTS `m-organizations-ranks` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `organization` bigint(20) DEFAULT NULL,
  `name` text DEFAULT NULL,
  `permissions` text DEFAULT NULL,
  `added` datetime DEFAULT current_timestamp(),
  `addedBy` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`uid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-punishments
CREATE TABLE IF NOT EXISTS `m-punishments` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` bigint(20) DEFAULT NULL,
  `serial` tinytext NOT NULL,
  `ip` tinytext DEFAULT NULL,
  `type` tinytext NOT NULL DEFAULT 'tempban',
  `permanent` tinyint(4) NOT NULL DEFAULT 0,
  `start` datetime NOT NULL DEFAULT current_timestamp(),
  `end` datetime NOT NULL DEFAULT current_timestamp(),
  `admin` tinytext NOT NULL,
  `reason` text NOT NULL,
  `additionalInfo` text NOT NULL,
  `active` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=181 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-sapd-logs
CREATE TABLE IF NOT EXISTS `m-sapd-logs` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `key` tinytext NOT NULL,
  `addedBy` bigint(20) NOT NULL DEFAULT 0,
  `added` datetime NOT NULL DEFAULT current_timestamp(),
  `info` text NOT NULL,
  PRIMARY KEY (`uid`),
  KEY `Indeks 2` (`added`,`key`(100))
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-sapd-tickets
CREATE TABLE IF NOT EXISTS `m-sapd-tickets` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` bigint(20) NOT NULL DEFAULT 0,
  `issuer` bigint(20) NOT NULL DEFAULT 0,
  `amount` bigint(20) NOT NULL DEFAULT 0,
  `reason` text NOT NULL,
  `active` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`uid`),
  KEY `Indeks 2` (`user`)
) ENGINE=InnoDB AUTO_INCREMENT=2147 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-sara-parking
CREATE TABLE IF NOT EXISTS `m-sara-parking` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cost` int(11) NOT NULL,
  `issuer` varchar(255) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `vehicle_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-season-pass-codes
CREATE TABLE IF NOT EXISTS `m-season-pass-codes` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` text NOT NULL,
  `leftUses` int(11) NOT NULL DEFAULT 1,
  `added` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-trade-logs
CREATE TABLE IF NOT EXISTS `m-trade-logs` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `userA` bigint(20) NOT NULL DEFAULT 0,
  `userB` bigint(20) NOT NULL DEFAULT 0,
  `beforeItemsA` mediumtext NOT NULL,
  `beforeItemsB` mediumtext NOT NULL,
  `itemsA` mediumtext NOT NULL,
  `itemsB` mediumtext NOT NULL,
  `afterItemsA` mediumtext NOT NULL,
  `afterItemsB` mediumtext NOT NULL,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`uid`),
  KEY `user and date` (`date`,`userA`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=577 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-ui-errors
CREATE TABLE IF NOT EXISTS `m-ui-errors` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `player` bigint(20) NOT NULL DEFAULT 0,
  `hash` text NOT NULL,
  `message` text NOT NULL,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`uid`),
  UNIQUE KEY `hash` (`hash`(100)),
  KEY `date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-users
CREATE TABLE IF NOT EXISTS `m-users` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `username` text NOT NULL,
  `password` text NOT NULL,
  `email` text NOT NULL,
  `ip` text NOT NULL,
  `serial` text NOT NULL,
  `detectedDiscordID` text NOT NULL,
  `skin` int(11) NOT NULL DEFAULT 0,
  `money` int(11) NOT NULL DEFAULT 0,
  `bankMoney` int(11) NOT NULL DEFAULT 10000,
  `level` int(11) NOT NULL DEFAULT 1,
  `exp` int(11) NOT NULL DEFAULT 0,
  `time` int(11) DEFAULT 0,
  `afkTime` int(11) DEFAULT 0,
  `dutyTime` int(11) unsigned DEFAULT 0,
  `payDutyTime` int(11) DEFAULT 0,
  `dailyRewardDay` int(11) DEFAULT 1,
  `mission` int(11) DEFAULT 1,
  `dailyRewardRedeem` datetime DEFAULT current_timestamp(),
  `lastActive` datetime NOT NULL DEFAULT current_timestamp(),
  `registerDate` datetime NOT NULL DEFAULT current_timestamp(),
  `premiumDate` datetime NOT NULL DEFAULT '1970-01-01 00:00:00',
  `settings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[ { "interfaceBlur": "0.4", "interfaceSize": "14" } ]',
  `seasonPassBought` tinyint(4) DEFAULT 0,
  `seasonPassData` longtext DEFAULT '[{}]',
  `avatar` text DEFAULT NULL,
  `knownIntros` text DEFAULT '',
  `inventory` mediumtext DEFAULT '[[]]',
  `collectibles` longtext DEFAULT '[{}]',
  `discordAccount` tinytext DEFAULT NULL,
  `discordCode` tinytext NOT NULL,
  `licenses` tinytext NOT NULL DEFAULT '',
  `lastPosition` tinytext NOT NULL DEFAULT '0,0,0',
  `catchedFishes` bigint(20) DEFAULT 0,
  `boughtCars` bigint(20) DEFAULT 0,
  `miningLevel` int(11) NOT NULL DEFAULT 1,
  `coal` bigint(20) NOT NULL,
  `totalCoal` bigint(20) NOT NULL,
  `taxes` int(11) NOT NULL,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`(100)),
  UNIQUE KEY `email` (`email`(100)),
  KEY `emailUsernamePassword` (`email`(100),`username`(100),`password`(100))
) ENGINE=InnoDB AUTO_INCREMENT=1224 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-users-logs
CREATE TABLE IF NOT EXISTS `m-users-logs` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `player` bigint(20) NOT NULL DEFAULT 0,
  `type` int(11) NOT NULL DEFAULT 1,
  `log` text NOT NULL,
  `details` text DEFAULT NULL,
  `date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`uid`),
  KEY `Indeks 2` (`player`),
  KEY `Indeks 3` (`date`)
) ENGINE=InnoDB AUTO_INCREMENT=21120 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-vehicles
CREATE TABLE IF NOT EXISTS `m-vehicles` (
  `uid` bigint(20) NOT NULL AUTO_INCREMENT,
  `owner` bigint(20) NOT NULL DEFAULT 0,
  `lastDriver` bigint(20) NOT NULL DEFAULT 0,
  `sharedPlayers` text NOT NULL DEFAULT '',
  `organization` bigint(20) NOT NULL DEFAULT 0,
  `model` int(11) NOT NULL DEFAULT 401,
  `fuel` decimal(20,6) NOT NULL DEFAULT 100.000000,
  `maxFuel` decimal(20,6) NOT NULL DEFAULT 100.000000,
  `lpg` int(11) NOT NULL DEFAULT 0,
  `lpgFuel` float NOT NULL DEFAULT 0,
  `lpgState` int(11) NOT NULL DEFAULT 0,
  `mileage` decimal(20,6) NOT NULL DEFAULT 0.000000,
  `engineCapacity` decimal(3,1) NOT NULL DEFAULT 1.0,
  `health` int(11) NOT NULL DEFAULT 1000,
  `fuelType` tinytext NOT NULL DEFAULT 'petrol',
  `plate` tinytext NOT NULL DEFAULT 'petrol',
  `buyDate` datetime NOT NULL DEFAULT current_timestamp(),
  `position` text NOT NULL,
  `rotation` text NOT NULL,
  `color` text NOT NULL DEFAULT '255,255,255,255,255,255,255,255,255,255,255,255',
  `wheelsColor` text NOT NULL DEFAULT '255,255,255,255,255,255',
  `panels` text NOT NULL DEFAULT '0,0,0,0,0,0,0',
  `doors` text NOT NULL DEFAULT '0,0,0,0,0,0',
  `lights` text NOT NULL DEFAULT '0,0,0,0',
  `wheels` text NOT NULL DEFAULT '0,0,0,0',
  `tuning` text NOT NULL DEFAULT '',
  `dirt` text NOT NULL DEFAULT '1,1',
  `exchangeData` text DEFAULT NULL,
  `mechanical` text NOT NULL DEFAULT '',
  `parking` int(11) NOT NULL DEFAULT 0,
  `frozen` int(11) NOT NULL DEFAULT 0,
  `engine` int(11) NOT NULL DEFAULT 0,
  `lightsState` int(11) NOT NULL DEFAULT 0,
  `parkingDate` datetime NOT NULL DEFAULT current_timestamp(),
  `shieldColor` varchar(255) NOT NULL DEFAULT '255,255,255',
  `carTint` int(11) NOT NULL,
  PRIMARY KEY (`uid`),
  KEY `owner` (`owner`),
  KEY `model` (`model`)
) ENGINE=InnoDB AUTO_INCREMENT=458 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-vehicles-police
CREATE TABLE IF NOT EXISTS `m-vehicles-police` (
  `uid` int(11) NOT NULL,
  `cost` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  `playerName` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela db_107401.m-whitelist
CREATE TABLE IF NOT EXISTS `m-whitelist` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `user` text NOT NULL,
  `serial` text NOT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
