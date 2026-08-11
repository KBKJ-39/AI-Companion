# AI Companion (rAthena)

AI Companion hire system for rAthena, with a `@companion` command (alias `@cp`)
that opens the NPC menu from anywhere on the map (no need to walk to the NPC).

## Features

- Hire up to 3 AI soldiers (in-game monster characters such as Seyren, Eremes, Margaretha, Kathryne, etc.)
- Companions have their own level (max 999), gain EXP from killing monsters, and auto-revive after death
- Automatically buffs the player (Assumptio, Kyrie, Blessing, Magnificat, etc., depending on the class)
- Equip/unequip gear on companions (weapon, shield, headgear, armor) and customize stats per level
- Automatically pulls nearby ground items to the player
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
│   └── src/map/atcommand.cpp        # Full file, command already added
└── npc/
    └── custom/
        └── companion_friend.txt     # AI Companion NPC script
```

## Requirements

- A current rAthena build (tested on `Release` / Windows MSVC + using `<npc/scripts_custom.conf>`)
- This guide assumes the server root is `<server>`
- **Version note:** the `copy-to-server/` files are full files built against one specific rAthena revision. If your target server is a different revision, use the `patches/` method instead (it merges cleanly into your own code).

## Supported Server Versions

**Tested on:** rAthena `master` commit `2fe6ab3` (Aug 8, 2026) · Renewal · PACKETVER `20250716` · Windows MSVC (Release)

**Recommended minimum:** rAthena `master` from mid-2024 onward (based on the script APIs used).

| API used | Added in rAthena | Why |
|---|---|---|
| `summon`, `unitexists`, `getmonsterinfo`, `getmapunits`, `getinventorylist`, `getiteminfo`, `sc_start` | Very old (pre-2015) | Core features |
| `getunitdata` / `setunitdata` + `UMOB_*` | 2015 (commit `2cee5b6`) | Control companion stats |
| `UMOB_MATKMIN` / `UMOB_MATKMAX` | 2019 (PR #3968) | Set MATK in `OnScale` |
| `UMOB_RES` / `UMOB_MRES` | 2022 (PR #6857) | Set RES/MRES in `OnScale` |
| `getbaseexp_ratio` | 2022 (EP 17.1 quests) | Compute EXP up to level 999 |

**If your server is older than the minimum:**
- `UMOB_RES` / `UMOB_MRES` missing → error when loading/running `OnScale` → **delete the 2 lines** in the `OnScale` label using `#COMPANION_BS[.@idx * 20 + 17]` and `+ 18` (plus `.@s == 17` / `.@s == 18` in `OnStatMenu`). It still works, but RES/MRES cannot be customized.
- `UMOB_MATKMIN` / `UMOB_MATKMAX` missing → mage-class companions get wrong damage → in `OnScale`, fall back to `UMOB_ATKMIN/ATKMAX` only.
- The `patches/` method always merges into your own revision, but you must adapt the code to the APIs that exist there.

**Quick version check from git:**

```bash
git rev-parse HEAD              # e.g. 2fe6ab3dc4d830b11d93fb44c3b48436571890bd
git log -1 --format="%cs %s"    # e.g. 2026-08-04 Fixed message length calculations (#10073)
```

---

## Installation

### Method A: Copy & Paste (fastest)

1. Copy the whole `copy-to-server/` folder over your server root (`<server>`), keeping the inner structure:

   ```
   copy-to-server/conf/atcommands.yml        ->  <server>/conf/atcommands.yml
   copy-to-server/npc/scripts_custom.conf    ->  <server>/npc/scripts_custom.conf
   copy-to-server/npc/custom/companion_friend.txt -> <server>/npc/custom/companion_friend.txt
   copy-to-server/src/map/atcommand.cpp      ->  <server>/src/map/atcommand.cpp
   ```

   > Note: the files in `copy-to-server/` are full files (already edited) — use them only if your target server runs the same rAthena revision as this package and you have not heavily customized `atcommand.cpp` / `atcommands.yml` / `scripts_custom.conf`.
2. Then continue with the **shared step (recompile)** and the **final step (reloadscript)** below.

### Method B: Patch the map-server source

From the rAthena root, apply the patch:

```bash
git apply patches/companion-all.patch
```

No git? Apply it manually (3 changes):

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

Register it in the command table (`atcommand_basecommands`, after `ACMD_DEF(help)`):

```cpp
		ACMD_DEF(help),
		ACMD_DEF(companion),
```

**2. `conf/atcommands.yml`**

Add an entry in `Body:` after the `help` block:

```yaml
  - Command: companion
    Aliases:
      - cp
    Help: |
      Opens the AI Companion menu (hire, release, check, equip your AI companions).
```

> Note: Do not use `ACMD_DEF2` to add the alias — atcommand aliases are defined exclusively through `atcommands.yml`.

**3. Install the NPC script**

Copy the script file to:

```
<server>/npc/custom/companion_friend.txt
```

Then open `<server>/npc/scripts_custom.conf` and add this line (in the `Basic Scripts` section):

```
npc: npc/custom/companion_friend.txt
```

### Shared step (both methods): Recompile

- Windows: rebuild with MSVC (same as your normal rAthena build), then replace the running `map-server.exe`
- Linux: `make` / `./configure && make map-server`

**Warning:** Stop the map-server before replacing the exe (Windows will lock the file otherwise).

### Final step: Reload scripts (no restart needed)

From the map-server console:

```
reloadscript
```

Or restart the whole server set.

---

## In-Game Usage

| Command | Effect |
|---|---|
| `@companion` or `@cp` | Opens the AI Companion menu (works anywhere, no need to reach the NPC) |
| Walk to the `AI Companion` NPC at Prontera 156,193 | Opens the menu normally |

Menu options: hire a companion / release / check status / equip gear / adjust stats.

## Troubleshooting

- **`npc_scriptcont: failed npc_checknear test.`** — Happens when the script is run with `nd->id` (the real NPC) while the player is far from the NPC; the distance check fails, the dialog gets stuck, and this also causes the `event queue is full` warning. Fix: run it through `fake_nd->id` (as the patch above does) so rAthena skips the distance check, same as item scripts.
- **`npc_event: player's event queue is full`** — If you still see it after installing the patch, make sure you are running the freshly compiled exe (this warning is a side effect of a stuck dialog; once dialogs open/close normally it disappears on its own).
- **Companion monsters (1799, 1800, 3226...) must exist in your server's database** — if the IDs differ in your rAthena version, edit the `set .@cls` values in the `OnHireMenu` label.

## Customization Ideas

- Max companions: change `3` in `OnHireMenu` and the `0..2` loops in every label
- Stat/HP formulas: edit the `OnScale` / `OnScaleFull` labels
- Buff types: edit the `OnCompanionBuff` label

---

## Idea & Development Credits

- **System idea:** KBKJ (creator of the AI Companion concept, since the author does not know how to write scripts)
- **Developer / code author:** AI Opencode — Model **Big Pickle** (free version) — responsible for everything: script design, bug fixes, the install package, and this README.

---

## License

Free for personal and commercial use, under the [rAthena License](https://github.com/rathena/rathena/blob/master/COPYING)
