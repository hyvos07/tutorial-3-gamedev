## Latihan Mandiri: Eksplorasi Mekanika Pergerakan

Fitur lanjutan yang saya kerjakan adalah sebagai berikut.

### 1. Double Jump
Pada fitur ini, saya memakai atribut `jumps_used` untuk tracking seberapa banyak jumps yang sudah dilakukan oleh pemain. Karena idealnya double jump tidak berlaku berkali-kali, maka jika `jumps_used` sudah sama dengan dua, mekanisme jump akan di lock sampai player sampai ke tanah (dengan `is_on_floor()`)

### 2. Sprint
Sprint/lari diimplementasi dengan mendeteksi jika pemain menahan Shift selama bergerak, yang dideteksi dengan flag `is_sprinting`:
```gdscript
is_sprinting = (
    Input.is_physical_key_pressed(KEY_SHIFT) and not is_crouching and abs(input_dir) > 0.0
)
```

### 3. Crouch
Fitur ini diimplementasi dengan memanfaatkan flag `is_crouching`, yaitu mendeteksi apakah player sedang ada di tanah dan juga menahan tombol panah bawah.
```gdscript
is_crouching = is_on_floor() and Input.is_action_pressed("ui_down")
```

### 4. Dodge/Dash
Fitur ini yang paling susah, karena harus mendeteksi interval double shift dan juga cooldown dash agar tidak bisa diabuse oleh pemain. Banyak elemen yang harus dilibatkan seperti `dodge_double_tap_window`, `dodge_cooldown`, dan lainnya.

Terdapat pula algoritma tersendiri yang akan menghitung dan validasi dari double-shift dash tadi, seperti berikut:
```gdscript
var now := Time.get_ticks_msec() / 1000.0
if now - last_shift_tap_time <= dodge_double_tap_window:
    dodge_requested = true
last_shift_tap_time = now
```

Selain keempat fitur tadi, ada juga modifikasi dan penambahan UI dari animasi, tantangan, dan juga polishment lainnya.


sori kak tadi ga lihat harus dijelasin di readme, last commit koding ada di [jam 5](https://github.com/hyvos07/tutorial-3-gamedev/commit/43dec0c1d1e3e9dee05c012077007343a19998cb) 😭😭😭