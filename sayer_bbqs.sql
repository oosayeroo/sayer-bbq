CREATE TABLE IF NOT EXISTS `sayer_bbq` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `prop` varchar(50) DEFAULT NULL,
  `item` varchar(50) DEFAULT NULL,
  `fuel` text DEFAULT NULL,
  `coords` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;