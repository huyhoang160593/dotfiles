# Mango 0.18: config key rename (breaking) và cách migrate

Research date: 2026-10-17. Machine: CachyOS/Arch (x86_64_v4), mangowm ("mango", dwl/wlroots-based) + Noctalia, fish, chezmoi.
Local versions: `mangowm 0.18.1-1.1` (package cài lúc 2026-10-17 20:59), session đang chạy khởi động 20:52 nên vẫn là binary **0.17.3** cũ, `noctalia 5.3.0-1.1`, `cachyos-mango-noctalia 1.4.1-1`.

## Question

Bản mango mới có breaking change gì, config hiện tại (do chezmoi quản lý) còn load được không, và đường migrate nào tốt nhất cho repo này?

## Findings

### 1. Breaking change của 0.18.0: đổi tên (tách) config key

Release note 0.18.0, mục **🔄 Breaking Changes**:

> "To make the configuration format appear more regular, some configuration keys have now been renamed/duplicated. Please use the following script to migrate them globally." — kèm link `migrate-config-keys.sh` và hướng dẫn `cd ~/.config/mango && bash migrate-config-keys.sh`.

Đây là rename thuần tuý: không có shim tương thích. Key cũ bị coi là **unknown keyword**, bị bỏ qua và mango log lỗi (xác nhận bằng binary 0.18.1 trên máy: `mango -p`).

Các thay đổi khác cùng đợt, **không ảnh hưởng config này**:

- 0.18.0: biến trong config (`var=name,value`, dùng `$name`/`${name}`), config TOML, `auto_reload_config` (docs ghi default `1`), `monocle_tab_mode`, `deck_tab_mode`, `monocle_no_gap`/`monocle_no_border`, `always_show_group_bar`, `group_bar_close_button_enable`, `disable_middle_paste`.
- 0.18.1: dispatcher `smartkillclient`, option `monocle_right_buttom_close`, và "Removed the double quotes surrounding values in the configuration file" + "Overly long configuration values are now rejected with an error". Config này **không có value nào bọc `"`** nên không dính.
- Rename/bỏ key của các bản trước đó mà repo này không dùng: 0.16.0 bỏ `ov_no_resize`; 0.16.1 tách option chuột/trackpad (prefix `mouse_`/`trackpad_`); 0.16.3 chuyển overview tab mode sang dispatcher `overcircle`; 0.17.0 bỏ `tablet_map_to_mon`, `touch_map_to_mon`.

### 2. Triệu chứng người dùng thấy: mangonag

Docs (Configuration → Miscellaneous → *Config errors*): khi config có lỗi, mango hiện thanh `mangonag` ở cạnh trên output đang focus, có nút **Close** (tắt) và **Edit** (mở lỗi đầu tiên trong `$EDITOR`/`$VISUAL`/`vi` tại đúng dòng). Đây là thứ hiện ra sau khi chạy binary 0.18.x với config cũ.

### 3. Config trong repo: 50 key bị bỏ, 7 file

Chạy `mango -p` (binary 0.18.1) trên `~/.config/mango/config.conf` → **50 lỗi "Unknown keyword"**, exit 1:

| File | Lỗi | Key cũ |
| --- | --- | --- |
| `cfg/appearance.conf` | 18 | `gappih`, `gappiv`, `gappoh`, `gappov`, `borderpx`, 8 color `*color`, `shadowscolor`, `fadein_begin_opacity`, `fadeout_begin_opacity`, 2 `animation_curve_opafade*` |
| `cfg/layout.conf` | 12 | `tagrule` ×9, `default_mfact`, `default_nmaster`, `smartgaps` |
| `noctalia.conf` | 10 | `rootcolor`, `bordercolor`, `dropcolor`, `splitcolor`, `focuscolor`, `maximizescreencolor`, `urgentcolor`, `scratchpadcolor`, `globalcolor`, `overlaycolor` |
| `cfg/autostart.conf` | 5 | `exec-once` ×5 |
| `cfg/rules.conf` | 4 | `windowrule` ×3, `layerrule` |
| `cfg/misc.conf` | 1 | `syncobj_enable` |

Rename tương ứng (theo `migrate-config-keys.sh` của upstream, đã đối chiếu docs):

| Cũ | Mới |
| --- | --- |
| `gappih/gappiv/gappoh/gappov` | `gap_inner_horizontal/gap_inner_vertical/gap_outer_horizontal/gap_outer_vertical` |
| `borderpx` | `border_px` |
| `rootcolor` `bordercolor` `focuscolor` `urgentcolor` `scratchpadcolor` `globalcolor` `overlaycolor` `maximizescreencolor` `shadowscolor` `dropcolor` `splitcolor` | `root_color` `border_color` `focus_color` `urgent_color` `scratchpad_color` `global_color` `overlay_color` `maximized_screen_color` `shadows_color` `drop_color` `split_color` |
| `fadein_begin_opacity` / `fadeout_begin_opacity` | `fade_in_begin_opacity` / `fade_out_begin_opacity` |
| `animation_curve_opafadein` / `...out` | `animation_curve_opacity_fade_in` / `..._fade_out` |
| `tagrule` / `windowrule` / `windowrule-once` / `layerrule` / `monitorrule` / `devicerule` | `tag_rule` / `window_rule` / `window_rule_once` / `layer_rule` / `monitor_rule` / `device_rule` |
| `isfloating` `appid` `noanim` `noblur` | `is_floating` `app_id` `no_animation` `no_blur` |
| `exec-once` / `source-optional` / `keymode` | `exec_once` / `source_optional` / `key_mode` |
| `syncobj_enable` / `smartgaps` | `sync_obj_enable` / `smart_gaps` |
| `default_mfact` / `default_nmaster` (và `mfact`→`master_factor`, `nmaster`→`master_count`) | `default_master_factor` / `default_master_count` |

(Tên mới của gaps/color/rule khớp đúng docs: Theming, TOML Conversion, Filesystem rules.)

### 4. Hệ quả thật khi mango 0.18.x start

Key bị bỏ ⇒ option về default của mango, không phải giá trị đã cấu hình:

- **`exec-once` (5 dòng) biến mất**: `noctalia &`, `fcitx5 -d`, `easyeffects --service-mode &`, `gnome-keyring-daemon --start ...`, `systemctl --user import-environment` **không chạy lúc compositor start**. Nghĩa là mất bar/shell Noctalia, mất IME, và mất fix env cho systemd user (bug theme Dolphin trong README §213 quay lại).
- **Màu**: cả `appearance.conf` lẫn `noctalia.conf` mất color key ⇒ rơi về default của mango (ví dụ `focus_color` default `0xc66b25ff` — cam, không còn teal của Noctalia).
- **Gaps**: rơi về `gap_inner_*` 5 / `gap_outer_*` 10 (đang đặt 10/10/20/20).
- **`tag_rule`**: tag 1 (scroller) và tag 2 (vertical_scroller) mất layout riêng, tag 3–9 cũng vậy — dùng layout mặc định.
- **`window_rule`/`layerrule`**: rule Steam floating và rule `layer_name:selection` (`no_anim`, `no_blur`) mất.
- `sync_obj_enable` bị bỏ nhưng default `sync_obj_enable` = 1 nên không đổi hành vi.

Thời điểm: package 0.18.1 cài 20:59 hôm nay, session đang chạy là binary 0.17.3 (start 20:52) ⇒ **config hiện vẫn chạy được, hỏng ở lần start mango kế tiếp (lần login/reload session sau)**, hoặc ngay khi reload config bằng binary mới.

### 5. Phần config không dính rename (đã verify sạch)

- `cfg/keybinds.conf`, `cfg/input.conf`, `cfg/env.conf`, `cursor.conf` (plugin `vn1k/cursor` own): 0 lỗi. Mọi dispatcher đang dùng (`toggleoverview`, `minimized`, `restore_minimized`, `set_proportion`, `switch_proportion_preset`, `incgaps`, `togglegaps`, `toggleglobal`, `toggleoverlay`, `exchange_client`, `togglefakefullscreen`, `togglemaximizescreen`, `moveresize`, `focusmon`, `tagmon`, `switch_layout`) vẫn tồn tại.
- `allow_tearing = 2` vẫn hợp lệ (2 = Fullscreen only).
- `cfg/monitors.conf`: dòng `monitorrule` đang comment nên không lỗi (script chỉ đổi phần comment).

### 6. Lỗi và tên cũ còn lại (không do 0.18, nhưng nên sửa cùng lượt)

- **2 keybinding conflict có sẵn** — `keybinds.conf:96,97` (`SUPER+ALT Left/Right` → `focusmon`) trùng `:99,100` (cùng tổ hợp → `tagmon`). `mango -p` report `Key binding conflict in keymode default` và exit 1 vì cảnh báo này (không fatal, một trong hai binding không bao giờ chạy).
- **Comment cũ trong `cfg/input.conf:7-8`**: `accel_profile`/`accel_speed` không còn là option global; tên đúng là `mouse_accel_profile`/`mouse_accel_speed` (và `trackpad_accel_*`). `accel_profile`/`accel_speed` trần chỉ còn hợp lệ **bên trong `device_rule`**.
- **Comment cũ trong `cfg/misc.conf:6`**: `# xwayland-persistence` — tên đúng là `xwayland_persistence` (dấu gạch dưới).
- **Docs trong repo còn tên cũ**: `README.md:74,213,260,276` và `docs/adr/0001-...md:22`, `docs/adr/0004-...md:3` đang viết `exec-once`. File config mới là `exec_once`.

### 7. Phía Noctalia: template đã đổi tên, file trên máy thì chưa

`~/.config/mango/noctalia.conf` là file **do Noctalia sinh**, nhưng template đã cài (`/usr/share/noctalia/assets/templates/mango/mango.conf`, noctalia 5.3.0-1.1) **đã dùng tên mới** (`root_color`, `border_color`, `drop_color`, `split_color`, `focus_color`, `maximized_screen_color`, ...). File trên máy vẫn tên cũ vì Noctalia chỉ ghi lại khi theme được apply. Tức là: muốn hết lỗi ngay thì đổi tên file này cùng lượt migrate; còn lần apply theme kế tiếp của Noctalia sẽ tự ghi tên mới (và hiện ra như chezmoi diff, chuyện có sẵn từ trước).

## Recommended migration

Migrate **trong chezmoi source**, verify bằng `mango -p` trước khi để nó vào session — vì chezmoi là source of truth và làm vậy máy mới cài lại không bị hỏng lần nữa.

```sh
# 1. Lấy script migrate chính thức của upstream (release 0.18.0)
curl -sL "https://github.com/user-attachments/files/33058895/migrate-config-keys.sh" -o /tmp/opencode/migrate-config-keys.sh

# 2. Dry-run, scope đúng cây config mango trong repo
cd ~/.local/share/chezmoi
bash /tmp/opencode/migrate-config-keys.sh -n dot_config/mango   # kỳ vọng: đúng 7 file

# 3. Đổi tên (git là backup; xem diff trước khi commit)
bash /tmp/opencode/migrate-config-keys.sh dot_config/mango

# 4. Verify bản render trước khi đụng session
chezmoi diff
chezmoi apply
mango -p          # kỳ vọng: hết "Unknown keyword" và hết keybinding conflict (0 lỗi)
```

Sau đó:

1. `mmsg dispatch reload_config` (hoặc `Super+R`) — nhưng **`exec_once` chỉ chạy lúc compositor start**, nên Noctalia/fcitx5/easyeffects/gnome-keyring cần **logout-login** (hoặc chạy tay ngay) để quay lại đúng trạng thái.
2. Cập nhật `README.md`: 4 chỗ `exec-once` + 1 dòng trỏ về doc này trong mục mangowm. ADR để nguyên (bản ghi lịch sử quyết định) — nếu muốn thì thêm note thay vì sửa thân ADR.
3. Sửa 2 keybinding conflict: `tagmon` → `SUPER+ALT+SHIFT Left/Right` (đây là 2 warning còn lại sau khi hết unknown keyword).
4. Không đổi sang TOML: xem mục "Vì sao" bên trên.

### Vì sao dùng script chính thức thay vì sửa tay / đổi sang TOML

- Script của upstream là hướng dẫn chính thức trong release note, cover cả rule type và directive (`window_rule_once`, `source_optional`, `keymode`, ...), có guard ranh giới từ (không đụng `mango/keymode` của Waybar, `#keymode` CSS, hay giá trị kiểu `my-appid`), và có sẵn `--dry-run` / `--backup`.
- **Đã test phạm vi**: dry-run trên cả repo chezmoi → chỉ 7 file trong `dot_config/mango` đổi, không đụng file `.conf`/`.toml`/`.sh` nào khác.
- TOML: docs hỗ trợ và có bảng chuyển đổi, nhưng là churn lớn (bind/rules đổi cấu trúc hẳn), không cần cho việc này. Chỉ nên làm nếu muốn, không phải để fix breaking change.

## Đã thực hiện (2026-10-17)

- Chạy `migrate-config-keys.sh` của upstream trên `dot_config/mango` trong chezmoi source: **7 file**, 28 key khác nhau / 50 lần. Thuần rename — đối chiếu value từng file với bản `HEAD`: không đổi (ngoại lệ có chủ ý: option *bên trong* rule của `rules.conf` cũng phải đổi tên, ví dụ `isfloating`→`is_floating`).
- Verify: render config đã migrate ra thư mục tạm và chạy `mango -p -c <config>` bằng binary 0.18.1 → **exit 0, không còn `Unknown keyword`, không còn keybinding conflict**.
- Sửa kèm: 2 keybinding conflict (`tagmon` → `SUPER+ALT+SHIFT`); comment cũ trong `input.conf` (`mouse_accel_*`) và `misc.conf` (`xwayland_persistence`); thêm newline cuối `autostart.conf`.
- Thêm guard fish `check_mango_config` rồi **gỡ lại** cùng ngày (1 function cho việc đã xong một lần là thừa; mango 0.18 đã có mangonag hiện lỗi lúc start, và `check_mango_stack` đã lo phần portal/service).
- Đã apply (2026-10-17): `chezmoi apply ~/.config/mango`, verify `mango -p` trên config live → exit 0, sạch. Cập nhật `README.md` (4 chỗ `exec_once` + dòng trỏ doc này). Sau apply phải **logout/login** thì `exec_once` mới chạy lại.

## Caveats / unknowns

- `migrate-config-keys.sh` là file đính kèm trong release GitHub (không nằm trong repo/gói). Đã đọc: 220 dòng bash + perl `s{...}{...}g`, chỉ rename whole-word, có chế độ dry-run. Vẫn nên xem như input bên ngoài.
- `mango -p` **exit code không đáng tin** (đo trên 0.18.1): có `[ERROR]` kiểu "Configuration value exceeds 255 bytes" mà vẫn exit **0**; exit **1** khi có unknown keyword hoặc keybinding conflict. Nên đọc output, đừng tin exit code.
- Chưa kiểm chứng hành vi value bọc `"` của 0.18.1 (release note nói bỏ việc strip quote): `mango -p` không bắt được case này, và config hiện tại không có value nào bọc quote nên không cần.
- Session đang chạy vẫn là 0.17.3 — **đừng `reload_config` (`Super+R` / `mmsg dispatch reload_config`) trước khi restart mango**: binary cũ chỉ biết tên key cũ nên reload bây giờ sẽ drop hết key mới (gaps, màu, rule, `exec_once`) trong session đang chạy. Restart đúng cách = logout/login.
- `noctalia.conf` do chezmoi track nhưng Noctalia sinh lại: sau migrate, một lần apply theme của Noctalia sẽ lại làm `chezmoi diff` bẩn (tình trạng có sẵn, không phải do lượt này).

## Sources

- Release 0.18.0 (breaking changes + script migrate): https://github.com/mangowm/mango/releases/tag/0.18.0 — API: https://api.github.com/repos/mangowm/mango/releases
- Release 0.18.1 (quote stripping, `-p` exit code, `monocle_right_buttom_close`, `smartkillclient`): https://github.com/mangowm/mango/releases/tag/0.18.1
- `migrate-config-keys.sh` (bảng rename gốc): https://github.com/user-attachments/files/33058895/migrate-config-keys.sh
- Docs — Basic Configuration (`exec_once`, `source_optional`, `var=`, `mango -c <file> -p`): https://mangowm.github.io/docs/configuration/basics
- Docs — TOML Conversion (tên rule type và option mới): https://mangowm.github.io/docs/configuration/toml
- Docs — Theming (`border_px`, `gap_*`, `root_color`, `maximized_screen_color`, ...): https://mangowm.github.io/docs/visuals/theming
- Docs — Miscellaneous (config errors → mangonag, `sync_obj_enable`, `auto_reload_config`, `xwayland_persistence`): https://mangowm.github.io/docs/configuration/miscellaneous
- Docs — Input Devices (`mouse_accel_*` / `trackpad_accel_*` vs `accel_*` trong device rule): https://mangowm.github.io/docs/configuration/input
- Docs — Monitors (`allow_tearing` 0/1/2): https://mangowm.github.io/docs/configuration/monitors
- Local: `mango -p` (binary 0.18.1, package `mangowm 0.18.1-1.1`), `/etc/mango/config.conf` (default config của gói, đã dùng tên mới), `/usr/share/noctalia/assets/templates/mango/mango.conf` (noctalia 5.3.0-1.1, tên mới).
