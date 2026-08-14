# AI Companion (rAthena)

AI Companion hire system for rAthena, with a `@companion` command (alias `@cp`)
that opens the NPC menu from anywhere on the map (no need to walk to the NPC).

**Latest version:** v1.8 — companion data is stored in **MySQL** (table `companion_db`),
so you can adjust stats directly from the database, just like editing player stats.

## Features

- Hire up to 3 AI soldiers (12 classes: Seyren, Eremes, Cenia, Howard, Margaretha, Cecil, Kathryne, Randel, Flamel, Celia, Chen, Gertie)
- Companions have their own level (max 999), gain EXP from killing monsters, and auto-revive after death
- 12 class-specific attack skills (Bowling Bash, Meteor Assault, Magnus, Storm Gust, Grand Cross, Meteor Storm, etc.) used automatically with cooldown
- Automatically buffs the player per class (Assumptio, Kyrie, Blessing, Magnificat, etc.)
- Equip/unequip gear on companions (weapon, shield, headgear, armor) + adjust 18 stats (STR..MRES) that scale with level
- Automatically pulls nearby ground items to the player
- Priest companion revives the player when they die
- **Data stored in MySQL** via `query_sql` — edit stats/level/EXP straight from the database
- `@companion` / `@cp` works from anywhere (uses the fake-NPC mechanism like item scripts, so no `npc_checknear` issues)

## Package Contents

```
AI-Companion/
├── README.md / README.EN.md
├── patches/                         # For servers that can git-apply
│   ├── atcommand.cpp.patch          # Adds the @companion command to map-server
│   ├── atcommands.yml.patch         # Adds the command entry in conf
│   └── companion-all.patch          # Both patches combined in one file
├── copy-to-server/                  # (recommended) just copy over your server
│   ├── conf/atcommands.yml          # Full file, already edited
│   ├── npc/scripts_custom.conf      # Full file, script load line already added
│   ├── npc/custom/companion_friend.txt
│   ├── sql-files/companion_db.sql   # MySQL table (must be imported first)
│   └── src/map/atcommand.cpp        # Full file, command already added
├── npc/
│   └── custom/
│       └── companion_friend.txt     # AI Companion NPC script
└── sql-files/
    └── companion_db.sql             # MySQL table that stores companion data
```

## Requirements

- Current rAthena (tested on `Release` / Windows MSVC, using `<npc/scripts_custom.conf>`)
- File paths below assume the server root is `<server>`
- **Package version:** the `copy-to-server` method works only on the same rAthena version the package was built for. If your server is a different version, use `patches/` instead (it merges into your code).
- A working MySQL instance for rAthena (the script reads/writes the `companion_db` table in the game database).

### Supported Server Versions

**Tested with:** rAthena `master` · Renewal · Windows MSVC (Release)

**Recommended minimum:** rAthena `master` from mid-2024 onward (based on the APIs used).

| API used | Available since | Reason |
|---|---|---|
| `summon`, `unitexists`, `getmonsterinfo`, `getareaunits`, `getinventorylist`, `getiteminfo`, `sc_start` | very old (before 2015) | basic features |
| `getunitdata` / `setunitdata` + `UMOB_*` | 2015 (commit `2cee5b6`) | control companion stats |
| `UMOB_MATKMIN` / `UMOB_MATKMAX` | 2019 (PR #3968) | set MATK in `OnScale` |
| `UMOB_RES` / `UMOB_MRES` | 2022 (PR #6857) | set RES/MRES in `OnScale` |
| `getbaseexp_ratio` | 2022 (EP 17.1 quests) | EXP calculation up to level 999 |
| `query_sql` | very old | read/write the `companion_db` table |

> Note: v1.7+ uses `getareaunits` instead of `getmapunits` to scan only the local area (fixes the infinity loop). If your server is too old to have `getareaunits`, fall back to `getmapunits` and adjust the loop range yourself.

**If your server is older than the minimum:**
- No `UMOB_RES` / `UMOB_MRES` → error when loading `OnScale` → **remove the 2 lines** in `OnScale` that use `#COMPANION_BS[.@idx * 20 + 17]` and `+ 18` (and the `.@s == 17` / `.@s == 18` checks in `OnStatMenu`). You lose RES/MRES adjustment but everything else works.
- No `UMOB_MATKMIN` / `UMOB_MATKMAX` → mage stats are wrong → change `OnScale` to use only `UMOB_ATKMIN/ATKMAX`.
- The `patches/` method always merges, but you must adjust the code to compile against the APIs available in your version.

---

## Installation

### Step 0: import the MySQL table (new since v1.8)

Create the `companion_db` table in the game database (run once):

```bash
mysql -u ragnarok -p ragnarok < sql-files/companion_db.sql
```

Or import `companion_db.sql` via phpMyAdmin / HeidiSQL.

> The script will not work without this table — `OnCompLoad`/`OnCompSave` use `query_sql` on every change.

### Method A: copy-paste (fastest)

1. Copy the whole `copy-to-server/` folder over the server root (`<server>`), keeping the same layout:

   ```
   copy-to-server/conf/atcommands.yml        ->  <server>/conf/atcommands.yml
   copy-to-server/npc/scripts_custom.conf    ->  <server>/npc/scripts_custom.conf
   copy-to-server/npc/custom/companion_friend.txt -> <server>/npc/custom/companion_friend.txt
   copy-to-server/sql-files/companion_db.sql ->  <server>/sql-files/companion_db.sql
   copy-to-server/src/map/atcommand.cpp      ->  <server>/src/map/atcommand.cpp
   ```

   > Note: files in `copy-to-server/` are full files (already edited) — only valid if your server is the same rAthena version as the package and you haven't specially modified `atcommand.cpp` / `atcommands.yml` / `scripts_custom.conf`.
2. Continue with **common step (recompile)** and **final step (reloadscript)**.

### Method B: patch map-server code

From the rAthena root, use git apply:

```bash
git apply patches/companion-all.patch
```

If git is not available or you prefer to do it manually, edit 2 places:

**1. `src/map/atcommand.cpp`**

Add this function right after `ACMD_FUNC(help)` (~line 1856):

```cpp
/*==========================================
 * @companion
 *------------------------------------------*/
ACMD_FUNC(companion){
	nullpo_retr(-1, sd);

	if (sd->npc_id != 0) {
		clif_displaymessage(fd, "Please close the current window first before using this command.");
		return -1;
	}

	npc_data* nd = npc_name2id("AI Companion");
	if (nd == nullptr || nd->subtype != NPCTYPE_SCRIPT) {
		clif_displaymessage(fd, "The AI Companion NPC could not be found.");
		return -1;
	}

	// Run the dialog through the fake NPC so it works from any distance
	// (npc_scriptcont skips the npc_checknear test for fake NPCs).
	run_script(nd->u.scr.script, 0, sd->id, fake_nd->id);
	return 0;
}
```

Register it in the command table (`atcommand_basecommands`, right after `ACMD_DEF(help)`):

```cpp
		ACMD_DEF(help),
		ACMD_DEF(companion),
```

**2. `conf/atcommands.yml`**

Add an entry in `Body:` right after the `help` block:

```yaml
  - Command: companion
    Aliases:
      - cp
    Help: |
      Opens the AI Companion menu (hire, release, check, equip your AI companions).
```

> Note: do not use `ACMD_DEF2` to add the alias — atcommand aliases are defined via `atcommands.yml` only.

**3. Place the NPC script**

Copy the script to:

```
<server>/npc/custom/companion_friend.txt
```

Then open `<server>/npc/scripts_custom.conf` and add this line (in `Basic Scripts`):

```
npc: npc/custom/companion_friend.txt
```

### Common step (both A and B): recompile

- Windows: rebuild with MSVC (same as a normal rAthena build) then replace the running `map-server.exe`
- Linux: `make` / `./configure && make map-server`

**Warning:** stop map-server before replacing the exe (Windows locks the file otherwise).

### Final step: reload scripts (no restart needed)

On the map-server console:

```
reloadscript
```

Or restart the whole server.

---

## In-Game Usage

| Command | Effect |
|---|---|
| `@companion` or `@cp` | Opens the AI Companion menu (works from anywhere) |
| Talk to the `AI Companion` NPC at Prontera 156,193 | Opens the menu normally |

Menu options: hire a companion / release / check status / equip / adjust stats.

## Managing Data via MySQL

All data is stored in the `companion_db` table (1 row per `char_id` + `slot`):

| Column | Meaning |
|---|---|
| `char_id`, `slot` | player + slot (0..2) — primary key |
| `class`, `name` | class + name |
| `level`, `exp` | level (max 999) + EXP |
| `weapon`, `shield`, `helm`, `armor` | equipped items (item IDs) |
| `val_*` / `lvl_*` | 18 stats (STR..MRES) + the level they were set at |

**Edit stats directly from the DB** (takes effect on that player's next login):

```sql
-- Set STR = 500 (grown from level 1) for companion slot 0 of char_id 150
UPDATE companion_db SET val_str = 500, lvl_str = 1 WHERE char_id = 150 AND slot = 0;
```

> The system loads from this table on login (`OnCompLoad`) and saves on every data change
> (`OnCompSave` — hire/release/level-up/equip/stat adjust). Existing players are migrated
> into the table automatically on their first login.

## Troubleshooting

- **`npc_scriptcont: failed npc_checknear test.`** — happens when the script runs with `nd->id` (the real NPC) and the player is too far away, so the distance check fails and the dialog hangs; also causes the `event queue is full` warning. Fix: run via `fake_nd->id` (see patch above) so rAthena skips the distance check like an item script.
- **`npc_event: player's event queue is full`** — if you still see it after installing the patch, check that you're using the freshly compiled exe (this warning is a result of the stuck dialog; it goes away once dialogs open/close normally).
- **`script:query_sql: ... Unknown table 'companion_db'`** — you forgot to import `companion_db.sql` (step 0).
- **`script:run_script_main: infinity loop`** — make sure the script is v1.7+ (scans with `getareaunits`); the old `getmapunits` iterated the whole map and caused this.
- **The companion mobs (1799, 1800, 3226...) must exist in your server's DB.** If the IDs differ in your version, change the `set .@cls` values in `OnHireMenu`.

## Version History

| Version | Content |
|---|---|
| v1.0 | Base system (hire/release, equipment, 18 stats, EXP/level, follow, revive, class buffs, vacuum loot, wake on death) |
| v1.1 | Thai comments explaining every label |
| v1.2 | 12 class attack skills + cooldown (`OnCompanionSkill`) |
| v1.3 | Fixed `delete_timer` mismatch: ground skills use `unitskillusepos` |
| v1.4 | Fixed infinity loop when leveling up multiple levels at once |
| v1.5 | Faster skill casts (offset native skill cast time) |
| v1.6 | Fixed "reached level" `dispbottom` spam on every kill |
| v1.7 | Fixed infinity loop from `getmapunits`: scan local area with `getareaunits` |
| v1.8 | **Store data in MySQL** (`companion_db`) via `query_sql` + auto-migrate old players |

## Customization Ideas

- Max companions: change `3` in `OnHireMenu` and the `0..2` loops in every label
- Stat/HP formulas: edit `OnScale` / `OnScaleFull`
- Buffs: edit `OnCompanionBuff`
- Attack skills/cooldown: edit `OnCompanionSkill`

---

## Credits

- **Idea:** KBKJ (all AI Companion system ideas; cannot write scripts)
- **Developer / coder:** AI Opencode — Model **Big Pickle** (free tier) — responsible for everything: script design, bug fixes, install package, and this README

---

## License

Free for personal and commercial use under the [rAthena License](https://github.com/rathena/rathena/blob/master/COPYING)
