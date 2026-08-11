# AI Companion (rAthena)

ระบบจ้าง Companion AI ต่อสู้แทนผู้เล่น พร้อมคำสั่ง `@companion` (alias `@cp`)
เพื่อเปิดเมนู NPC จากที่ไหนก็ได้บนแผนที่ (ไม่ต้องเดินไปหา NPC)

## คุณสมบัติ

- จ้าง AI Soldier ได้สูงสุด 3 ตัว (ตัวละครมอนสเตอร์จากเกม เช่น Seyren, Eremes, Margaretha, Kathryne ฯลฯ)
- Companion มีเลเวลแยก (สูงสุด 999) เก็บ EXP จากการฆ่ามอนสเตอร์, ฟื้นคืนชีพอัตโนมัติหลังตาย
- ให้บัฟกับผู้เล่นอัตโนมัติ (Assumptio, Kyrie, Blessing, Magnificat ฯลฯ ตามสายอาชีพ)
- ใส่/ถอดอุปกรณ์ให้ companion (อาวุธ โล่ หัว เกราะ), ปรับสเตตตามเลเวล
- ดึงไอเทมบนพื้นใกล้ ๆ มาหาผู้เล่นอัตโนมัติ
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
│   └── src/map/atcommand.cpp        # ไฟล์เต็ม ที่เพิ่มคำสั่งแล้ว
└── npc/
    └── custom/
        └── companion_friend.txt     # สคริปต์ NPC AI Companion
```

## ข้อกำหนด

- rAthena รุ่นปัจจุบัน (ทดสอบบน `Release` / Windows MSVC + ใช้ `<npc/scripts_custom.conf>`)
- ตำแหน่งไฟล์ในคู่มือนี้สมมติให้ root ของเซิร์ฟเวอร์ = `<server>`
- **รุ่นที่ใช้ในแพ็กเกจ:** วิธี `copy-to-server` ใช้ได้กับ rAthena รุ่นเดียวกับที่แพ็กเกจนี้สร้างขึ้น หากเซิร์ฟเวอร์เป้าหมายเป็นคนละเวอร์ชัน ให้ใช้วิธี `patches/` แทน (จะ merge เข้ากับโค้ดของเวอร์ชันนั้นเอง)

## รุ่นเซิร์ฟเวอร์ที่รองรับ

**แพ็กเกจนี้ทดสอบกับ:** rAthena `master` คอมมิต `2fe6ab3` (8 ส.ค. 2026) · Renewal · PACKETVER `20250716` · Windows MSVC (Release)

**ขั้นต่ำที่แนะนำ:** rAthena `master` ตั้งแต่กลางปี 2024 เป็นต้นไป (อิงจาก API ที่สคริปต์ใช้)

| API ที่ใช้ | เริ่มมีใน rAthena | เหตุผล |
|---|---|---|
| `summon`, `unitexists`, `getmonsterinfo`, `getmapunits`, `getinventorylist`, `getiteminfo`, `sc_start` | เก่ามาก (ก่อน 2015) | ฟีเจอร์พื้นฐาน |
| `getunitdata` / `setunitdata` + `UMOB_*` | 2015 (commit `2cee5b6`) | ควบคุมสเตต companion |
| `UMOB_MATKMIN` / `UMOB_MATKMAX` | 2019 (PR #3968) | ตั้งค่า MATK ใน `OnScale` |
| `UMOB_RES` / `UMOB_MRES` | 2022 (PR #6857) | ตั้งค่า RES/MRES ใน `OnScale` |
| `getbaseexp_ratio` | 2022 (EP 17.1 quests) | คำนวณ EXP จนถึงเลเวล 999 |

**ถ้าเซิร์ฟเวอร์เก่ากว่าขั้นต่ำ:**
- `UMOB_RES` / `UMOB_MRES` ไม่มี → จะ error ขณะโหลดสคริปต์/รัน `OnScale` → **ลบ 2 บรรทัด** ใน label `OnScale` ที่ใช้ `#COMPANION_BS[.@idx * 20 + 17]` และ `+ 18` (พร้อมตัวแปร `.@s == 17` / `.@s == 18` ใน `OnStatMenu`) ก็ใช้ได้ แต่จะปรับ RES/MRES ไม่ได้
- `UMOB_MATKMIN` / `UMOB_MATKMAX` ไม่มี → ใช้ค่าสายเวทย์ไม่ถูก → แก้ `OnScale` เหลือ `UMOB_ATKMIN/ATKMAX` แทน
- วิธี `patches/` จะ merge เข้าโค้ดเวอร์ชันนั้นได้เสมอ แต่ต้องปรับให้คอมไพล์ผ่านตาม API ที่มีอยู่

**เครื่องหมายบอกเวอร์ชันจาก git** (ใช้ตรวจสอบได้เลย):

```bash
git rev-parse HEAD              # เช่น 2fe6ab3dc4d830b11d93fb44c3b48436571890bd
git log -1 --format="%cs %s"    # เช่น 2026-08-04 Fixed message length calculations (#10073)
```

---

## วิธีติดตั้ง

### วิธี A: คัดลอก-วาง (เร็วสุด)

1. คัดลอกทั้งโฟลเดอร์ `copy-to-server/` ไปวางทับที่ root ของเซิร์ฟเวอร์ (`<server>`) โดยให้โครงสร้างภายในตรงกัน:

   ```
   copy-to-server/conf/atcommands.yml        ->  <server>/conf/atcommands.yml
   copy-to-server/npc/scripts_custom.conf    ->  <server>/npc/scripts_custom.conf
   copy-to-server/npc/custom/companion_friend.txt -> <server>/npc/custom/companion_friend.txt
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

## แก้ไขปัญหา

- **`npc_scriptcont: failed npc_checknear test.`** — เกิดเมื่อสคริปต์ถูกรันด้วย `nd->id` (NPC ตัวจริง) แล้วผู้เล่นอยู่ไกล NPC จนตรวจระยะไม่ผ่าน dialog ค้าง และเป็นต้นเหตุของ warning `event queue is full` ด้วย แก้โดยรันผ่าน `fake_nd->id` (ตาม patch ข้างต้น) เพื่อให้ rAthena ข้ามการเช็กระยะทางแบบ item script
- **`npc_event: player's event queue is full`** — ถ้ายังเห็นหลังติดตั้ง patch ให้ตรวจว่าใช้ exe ที่คอมไพล์ใหม่แล้วหรือยัง (warning นี้เป็นผลจาก dialog ค้าง; เมื่อเปิด/ปิด dialog ได้ปกติก็จะหายไปเอง)
- **มอนสเตอร์ companion ที่ใช้ในสคริปต์ (1799, 1800, 3226...) ต้องมีใน db ของเซิร์ฟเวอร์นั้น** ถ้า ID ต่างรุ่น ให้แก้ค่า `set .@cls` ใน label `OnHireMenu`

## ตัวอย่างไอเดียปรับแต่ง

- จำนวน companion สูงสุด: แก้ `3` ใน `OnHireMenu` และลูป `0..2` ในทุก label
- สูตรสเตต/HP: แก้ใน label `OnScale` / `OnScaleFull`
- ประเภทบัฟ: แก้ใน label `OnCompanionBuff`

---

## ผู้คิดไอเดีย / ผู้พัฒนา

- **ผู้คิดไอเดียระบบ:** KBKJ (ไอเดียระบบ AI Companion ทั้งหมด, เพราะผู้เขียนสคริปต์ไม่เป็น)
- **ผู้พัฒนา / เขียนโค้ด:** AI Opencode — Model **Big Pickle** (รุ่นฟรี) — รับผิดชอบทุกส่วน ตั้งแต่ออกแบบสคริปต์, แก้ bug, ทำแพ็กเกจติดตั้ง และเขียน README

---

## License

ฟรีสำหรับใช้งานส่วนตัวและเชิงพาณิชย์ ภายใต้ [rAthena License](https://github.com/rathena/rathena/blob/master/COPYING)
