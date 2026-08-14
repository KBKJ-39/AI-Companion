# AI Companion (rAthena)

ระบบจ้าง Companion AI ต่อสู้แทนผู้เล่น พร้อมคำสั่ง `@companion` (alias `@cp`)
เพื่อเปิดเมนู NPC จากที่ไหนก็ได้บนแผนที่ (ไม่ต้องเดินไปหา NPC)

**เวอร์ชันล่าสุด:** v1.8 — ข้อมูล companion เก็บใน **MySQL** (ตาราง `companion_db`)
ปรับสเตตได้ตรง ๆ จากฐานข้อมูล เหมือนแก้ stat ผู้เล่น

## คุณสมบัติ

- จ้าง AI Soldier ได้สูงสุด 3 ตัว (12 สายอาชีพ: Seyren, Eremes, Cenia, Howard, Margaretha, Cecil, Kathryne, Randel, Flamel, Celia, Chen, Gertie)
- Companion มีเลเวลแยก (สูงสุด 999) เก็บ EXP จากการฆ่ามอนสเตอร์, ฟื้นคืนชีพอัตโนมัติหลังตาย
- มีสกิลโจมตีประจำสาย 12 แบบ (Bowling Bash, Meteor Assault, Magnus, Storm Gust, Grand Cross, Meteor Storm ฯลฯ) ใช้เองอัตโนมัติพร้อม cooldown
- ให้บัฟกับผู้เล่นอัตโนมัติตามสายอาชีพ (Assumptio, Kyrie, Blessing, Magnificat ฯลฯ)
- ใส่/ถอดอุปกรณ์ให้ companion (อาวุธ โล่ หัว เกราะ) + ปรับสเตต 18 ค่า (STR..MRES) แบบมีผลโตตามเลเวล
- ดึงไอเทมบนพื้นใกล้ ๆ มาหาผู้เล่นอัตโนมัติ
- Priest companion ปลุกให้อัตโนมัติเมื่อผู้เล่นตาย
- **เก็บข้อมูลลง MySQL** ผ่าน `query_sql` — แก้สเตต/เลเวล/EXP ได้จากฐานข้อมูลโดยตรง
- `@companion` / `@cp` เปิดเมนูได้ทุกที่ (ใช้กลไก fake NPC แบบ item script จึงไม่มีปัญหา `npc_checknear`)

## ไฟล์ในแพ็กเกจ

```
AI-Companion/
├── README.md / README.EN.md
├── patches/                         # สำหรับเซิร์ฟเวอร์ที่ git patch ได้
│   ├── atcommand.cpp.patch          # เพิ่มคำสั่ง @companion ใน map-server
│   ├── atcommands.yml.patch         # เพิ่ม entry คำสั่งใน conf
│   └── companion-all.patch          # รวม 2 patch ข้างบนในไฟล์เดียว
├── copy-to-server/                  # (แนะนำ) คัดลอก-วางทับได้เลย
│   ├── conf/atcommands.yml          # ไฟล์เต็ม ที่แก้เสร็จแล้ว
│   ├── npc/scripts_custom.conf      # ไฟล์เต็ม ที่เพิ่มบรรทัดโหลดสคริปต์แล้ว
│   ├── npc/custom/companion_friend.txt
│   ├── sql-files/companion_db.sql   # ตาราง MySQL (ต้อง import ก่อนใช้งาน)
│   └── src/map/atcommand.cpp        # ไฟล์เต็ม ที่เพิ่มคำสั่งแล้ว
├── npc/
│   └── custom/
│       └── companion_friend.txt     # สคริปต์ NPC AI Companion
└── sql-files/
    └── companion_db.sql             # ตาราง MySQL สำหรับเก็บข้อมูล companion
```

## ข้อกำหนด

- rAthena รุ่นปัจจุบัน (ทดสอบบน `Release` / Windows MSVC + ใช้ `<npc/scripts_custom.conf>`)
- ตำแหน่งไฟล์ในคู่มือนี้สมมติให้ root ของเซิร์ฟเวอร์ = `<server>`
- **รุ่นที่ใช้ในแพ็กเกจ:** วิธี `copy-to-server` ใช้ได้กับ rAthena รุ่นเดียวกับที่แพ็กเกจนี้สร้างขึ้น หากเซิร์ฟเวอร์เป้าหมายเป็นคนละเวอร์ชัน ให้ใช้วิธี `patches/` แทน (จะ merge เข้ากับโค้ดของเวอร์ชันนั้นเอง)
- ต้องมี MySQL ที่ rAthena ใช้อยู่แล้ว (สคริปต์อ่าน/เขียนตาราง `companion_db` ใน database เดียวกับตัวเกม)

### รุ่นเซิร์ฟเวอร์ที่รองรับ

**แพ็กเกจนี้ทดสอบกับ:** rAthena `master` · Renewal · Windows MSVC (Release)

**ขั้นต่ำที่แนะนำ:** rAthena `master` ตั้งแต่กลางปี 2024 เป็นต้นไป (อิงจาก API ที่สคริปต์ใช้)

| API ที่ใช้ | เริ่มมีใน rAthena | เหตุผล |
|---|---|---|
| `summon`, `unitexists`, `getmonsterinfo`, `getareaunits`, `getinventorylist`, `getiteminfo`, `sc_start` | เก่ามาก (ก่อน 2015) | ฟีเจอร์พื้นฐาน |
| `getunitdata` / `setunitdata` + `UMOB_*` | 2015 (commit `2cee5b6`) | ควบคุมสเตต companion |
| `UMOB_MATKMIN` / `UMOB_MATKMAX` | 2019 (PR #3968) | ตั้งค่า MATK ใน `OnScale` |
| `UMOB_RES` / `UMOB_MRES` | 2022 (PR #6857) | ตั้งค่า RES/MRES ใน `OnScale` |
| `getbaseexp_ratio` | 2022 (EP 17.1 quests) | คำนวณ EXP จนถึงเลเวล 999 |
| `query_sql` | เก่ามาก | อ่าน/เขียนตาราง `companion_db` |

> หมายเหตุ: สคริปต์เวอร์ชัน v1.7+ ใช้ `getareaunits` แทน `getmapunits` เพื่อสแกนเฉพาะบริเวณรอบตัว (แก้ infinity loop) — ถ้าเซิร์ฟเวอร์เก่ามากจนไม่มี `getareaunits` ให้ใช้ `getmapunits` แล้วแก้ระยะในลูปเอง

**ถ้าเซิร์ฟเวอร์เก่ากว่าขั้นต่ำ:**
- `UMOB_RES` / `UMOB_MRES` ไม่มี → จะ error ขณะโหลดสคริปต์/รัน `OnScale` → **ลบ 2 บรรทัด** ใน label `OnScale` ที่ใช้ `#COMPANION_BS[.@idx * 20 + 17]` และ `+ 18` (พร้อมตัวแปร `.@s == 17` / `.@s == 18` ใน `OnStatMenu`) ก็ใช้ได้ แต่จะปรับ RES/MRES ไม่ได้
- `UMOB_MATKMIN` / `UMOB_MATKMAX` ไม่มี → ใช้ค่าสายเวทย์ไม่ถูก → แก้ `OnScale` เหลือ `UMOB_ATKMIN/ATKMAX` แทน
- วิธี `patches/` จะ merge เข้าโค้ดเวอร์ชันนั้นได้เสมอ แต่ต้องปรับให้คอมไพล์ผ่านตาม API ที่มีอยู่

---

## วิธีติดตั้ง

### ขั้นตอน 0: import ตาราง MySQL (ใหม่ตั้งแต่ v1.8)

สร้างตาราง `companion_db` ใน database ของเกม (รันครั้งเดียว):

```bash
mysql -u ragnarok -p ragnarok < sql-files/companion_db.sql
```

หรือ import `companion_db.sql` ผ่าน phpMyAdmin / HeidiSQL ก็ได้

> สคริปต์จะไม่ทำงานถ้าขาดตารางนี้ เพราะ `OnCompLoad`/`OnCompSave` ใช้ `query_sql` อ่าน-เขียนทุกจุด

### วิธี A: คัดลอก-วาง (เร็วสุด)

1. คัดลอกทั้งโฟลเดอร์ `copy-to-server/` ไปวางทับที่ root ของเซิร์ฟเวอร์ (`<server>`) โดยให้โครงสร้างภายในตรงกัน:

   ```
   copy-to-server/conf/atcommands.yml        ->  <server>/conf/atcommands.yml
   copy-to-server/npc/scripts_custom.conf    ->  <server>/npc/scripts_custom.conf
   copy-to-server/npc/custom/companion_friend.txt -> <server>/npc/custom/companion_friend.txt
   copy-to-server/sql-files/companion_db.sql ->  <server>/sql-files/companion_db.sql
   copy-to-server/src/map/atcommand.cpp      ->  <server>/src/map/atcommand.cpp
   ```

   > หมายเหตุ: ไฟล์ใน `copy-to-server/` เป็นไฟล์เต็ม (แก้เสร็จแล้ว) — ใช้ได้เมื่อเซิร์ฟเวอร์เป้าหมายเป็น rAthena รุ่นเดียวกันกับแพ็กเกจ และไม่ได้แก้ไฟล์ `atcommand.cpp` / `atcommands.yml` / `scripts_custom.conf` เป็นพิเศษมาก่อน
2. ทำต่อตาม **ขั้นตอนร่วม (คอมไพล์)** และ **ขั้นตอนสุดท้าย (reloadscript)**

### วิธี B: พาทช์โค้ด map-server

ไปที่โฟลเดอร์ root ของ rAthena แล้วใช้ git apply:

```bash
git apply patches/companion-all.patch
```

ถ้า git ไม่พร้อม หรือต้องการลงมือเอง ให้แก้ 2 จุด:

**1. `src/map/atcommand.cpp`**

เพิ่มฟังก์ชันต่อจาก `ACMD_FUNC(help)` (บรรทัด ~1856):

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

ลงทะเบียนในตารางคำสั่ง (`atcommand_basecommands`, ต่อจาก `ACMD_DEF(help)`):

```cpp
		ACMD_DEF(help),
		ACMD_DEF(companion),
```

**2. `conf/atcommands.yml`**

เพิ่ม entry ใน `Body:` ต่อจาก block ของ `help`:

```yaml
  - Command: companion
    Aliases:
      - cp
    Help: |
      Opens the AI Companion menu (hire, release, check, equip your AI companions).
```

> หมายเหตุ: อย่าใช้ `ACMD_DEF2` เพิ่ม alias แทน เพราะ alias ของ atcommand กำหนดผ่าน `atcommands.yml` เท่านั้น

**3. วางสคริปต์ NPC**

คัดลอกไฟล์สคริปต์ไปที่:

```
<server>/npc/custom/companion_friend.txt
```

จากนั้นเปิด `<server>/npc/scripts_custom.conf` แล้วเพิ่มบรรทัด (ส่วน `Basic Scripts`):

```
npc: npc/custom/companion_friend.txt
```

### ขั้นตอนร่วม (ทั้งวิธี A และ B): คอมไพล์ใหม่

- Windows: build ใหม่ด้วย MSVC (เหมือนตอน build rAthena ปกติ) แล้วแทนที่ `map-server.exe` ที่กำลังรันอยู่
- Linux: `make` / `./configure && make map-server`

**คำเตือน:** ต้องปิด map-server ก่อนแทนที่ exe (ไม่งั้น Windows จะล็อกไฟล์)

### ขั้นตอนสุดท้าย: รีโหลดสคริปต์ (ไม่ต้องรีสตาร์ท)

บน console ของ map-server:

```
reloadscript
```

หรือรีสตาร์ทเซิร์ฟเวอร์ทั้งชุด

---

## วิธีใช้งาน (ในเกม)

| คำสั่ง | ผล |
|---|---|
| `@companion` หรือ `@cp` | เปิดเมนู AI Companion (ใช้ได้ทุกตำแหน่ง ไม่ต้องเดินไปหา NPC) |
| เดินไปแตะ NPC `AI Companion` ที่ Prontera 156,193 | เปิดเมนูแบบปกติ |

เมนูประกอบด้วย: จ้าง companion / ปลด / ตรวจสอบสถานะ / ใส่อุปกรณ์ / ปรับสเตต

## จัดการข้อมูลผ่าน MySQL

ข้อมูลทั้งหมดเก็บในตาราง `companion_db` (1 แถว ต่อ `char_id` + `slot`):

| คอลัมน์ | ความหมาย |
|---|---|
| `char_id`, `slot` | ผู้เล่น + ช่อง (0..2) — primary key |
| `class`, `name` | สายอาชีพ + ชื่อ |
| `level`, `exp` | เลเวล (สูงสุด 999) + EXP |
| `weapon`, `shield`, `helm`, `armor` | ไอเทมที่สวม (item ID) |
| `val_*` / `lvl_*` | สเตต 18 ค่า (STR..MRES) + เลเวลที่ตั้งค่าไว้ |

**แก้สเตตตรง ๆ จาก DB** (ค่ามีผลตอน re-login ผู้เล่นคนนั้น):

```sql
-- ตั้งค่า STR = 500 (เริ่มคิดจากเลเวล 1) ให้ companion ช่อง 0 ของ char_id 150
UPDATE companion_db SET val_str = 500, lvl_str = 1 WHERE char_id = 150 AND slot = 0;
```

> ระบบโหลดจากตารางนี้ตอน login (`OnCompLoad`) และบันทึกทุกครั้งที่ข้อมูลเปลี่ยน
> (`OnCompSave` — จ้าง/ปลด/อัปเลเวล/ใส่อุปกรณ์/ปรับสเตต) ผู้เล่นเก่าที่มีข้อมูลอยู่แล้วจะถูก migrate เข้าตารางอัตโนมัติครั้งแรกที่ login

## แก้ไขปัญหา

- **`npc_scriptcont: failed npc_checknear test.`** — เกิดเมื่อสคริปต์ถูกรันด้วย `nd->id` (NPC ตัวจริง) แล้วผู้เล่นอยู่ไกล NPC จนตรวจระยะไม่ผ่าน dialog ค้าง และเป็นต้นเหตุของ warning `event queue is full` ด้วย แก้โดยรันผ่าน `fake_nd->id` (ตาม patch ข้างต้น) เพื่อให้ rAthena ข้ามการเช็กระยะทางแบบ item script
- **`npc_event: player's event queue is full`** — ถ้ายังเห็นหลังติดตั้ง patch ให้ตรวจว่าใช้ exe ที่คอมไพล์ใหม่แล้วหรือยัง (warning นี้เป็นผลจาก dialog ค้าง; เมื่อเปิด/ปิด dialog ได้ปกติก็จะหายไปเอง)
- **`script:query_sql: ... Unknown table 'companion_db'`** — ลืม import `companion_db.sql` (ขั้นตอน 0)
- **infinity loop / `script:run_script_main: infinity loop`** — ตรวจว่าสคริปต์เป็น v1.7+ ซึ่งสแกนด้วย `getareaunits` แบบจำกัดบริเวณแล้ว (ต้นเหตุเดิมคือ `getmapunits` วนทั้งแผนที่)
- **มอนสเตอร์ companion ที่ใช้ในสคริปต์ (1799, 1800, 3226...) ต้องมีใน db ของเซิร์ฟเวอร์นั้น** ถ้า ID ต่างรุ่น ให้แก้ค่า `set .@cls` ใน label `OnHireMenu`

## ประวัติเวอร์ชัน

| เวอร์ชัน | เนื้อหา |
|---|---|
| v1.0 | ระบบพื้นฐาน (จ้าง/ปลด, อุปกรณ์, สเตต 18 ค่า, EXP/เลเวล, ติดตามผู้เล่น, ฟื้นคืนชีพ, บัฟสายอาชีพ, vacuum loot, ปลุกเมื่อตาย) |
| v1.1 | เพิ่มคอมเมนต์ภาษาไทยอธิบายทุก label |
| v1.2 | เพิ่มระบบสกิลโจมตีประจำสาย 12 สาย + cooldown (`OnCompanionSkill`) |
| v1.3 | แก้ `delete_timer` mismatch: สกิล Ground ใช้ `unitskillusepos` |
| v1.4 | แก้ infinity loop ตอนอัปเลเวลทีเดียวหลายระดับ |
| v1.5 | เร่งความเร็วร่ายสกิล (ชดเชย cast time ดั้งเดิมของสกิล) |
| v1.6 | แก้ `dispbottom` "reached level" ซ้ำทุกรอบ kill |
| v1.7 | แก้ infinity loop จาก `getmapunits`: สแกนรอบบริเวณด้วย `getareaunits` |
| v1.8 | **เก็บข้อมูลลง MySQL** (ตาราง `companion_db`) ผ่าน `query_sql` + migrate ผู้เล่นเก่า |

## ตัวอย่างไอเดียปรับแต่ง

- จำนวน companion สูงสุด: แก้ `3` ใน `OnHireMenu` และลูป `0..2` ในทุก label
- สูตรสเตต/HP: แก้ใน label `OnScale` / `OnScaleFull`
- ประเภทบัฟ: แก้ใน label `OnCompanionBuff`
- สกิลโจมตี/cooldown: แก้ใน label `OnCompanionSkill`

---

## ผู้คิดไอเดีย / ผู้พัฒนา

- **ผู้คิดไอเดียระบบ:** KBKJ (ไอเดียระบบ AI Companion ทั้งหมด, เพราะผู้เขียนสคริปต์ไม่เป็น)
- **ผู้พัฒนา / เขียนโค้ด:** AI Opencode — Model **Big Pickle** (รุ่นฟรี) — รับผิดชอบทุกส่วน ตั้งแต่ออกแบบสคริปต์, แก้ bug, ทำแพ็กเกจติดตั้ง และเขียน README

---

## License

ฟรีสำหรับใช้งานส่วนตัวและเชิงพาณิชย์ ภายใต้ [rAthena License](https://github.com/rathena/rathena/blob/master/COPYING)
