-- ============================================================
-- AI Companion (companion_friend.txt) - Player-like stat storage
-- One row per (char_id, slot). The script reads/writes this
-- table with query_sql so you can adjust stats directly in MySQL.
-- Import into the 'ragnarok' database, e.g.:
--   mysql -u ragnarok -p ragnarok < companion_db.sql
-- ============================================================

CREATE TABLE IF NOT EXISTS `companion_db` (
  `char_id` INT UNSIGNED NOT NULL DEFAULT '0',
  `slot` TINYINT UNSIGNED NOT NULL DEFAULT '0',
  `class` INT UNSIGNED NOT NULL DEFAULT '0',
  `name` VARCHAR(30) NOT NULL DEFAULT '',
  `level` INT UNSIGNED NOT NULL DEFAULT '1',
  `exp` BIGINT UNSIGNED NOT NULL DEFAULT '0',
  `weapon` SMALLINT UNSIGNED NOT NULL DEFAULT '0',
  `shield` SMALLINT UNSIGNED NOT NULL DEFAULT '0',
  `helm` SMALLINT UNSIGNED NOT NULL DEFAULT '0',
  `armor` SMALLINT UNSIGNED NOT NULL DEFAULT '0',
  -- custom stat bonuses (0 = use default formula)
  `val_str` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_agi` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_vit` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_int` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_dex` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_luk` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_atk` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_matk` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_maxhp` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_def` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_mdef` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_hit` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_flee` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_crit` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_aspd` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_pdodge` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_res` INT UNSIGNED NOT NULL DEFAULT '0',
  `val_mres` INT UNSIGNED NOT NULL DEFAULT '0',
  -- companion level at which each bonus was set (for growth calc)
  `lvl_str` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_agi` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_vit` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_int` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_dex` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_luk` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_atk` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_matk` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_maxhp` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_def` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_mdef` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_hit` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_flee` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_crit` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_aspd` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_pdodge` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_res` INT UNSIGNED NOT NULL DEFAULT '0',
  `lvl_mres` INT UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`char_id`, `slot`),
  KEY `class` (`class`)
) ENGINE=InnoDB;
