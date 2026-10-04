# Ngữ cảnh Dotfiles

Repo dotfiles cá nhân quản lý bằng **chezmoi**, chạy trên **CachyOS** với shell **fish**, Wayland compositor **mangowm**, desktop shell và greeter **Noctalia**, terminal **Ghostty**, trình duyệt **Helium**, và prompt **Starship** với theme từ **Stellar**.

## Thuật ngữ

**chezmoi**:
Trình quản lý dotfile giữ source of truth trong repo git và áp dụng template lên thư mục home. Source nằm tại `~/.local/share/chezmoi`. Hỗ trợ Go template cho tất cả file (`.tmpl`), bao gồm `.chezmoiignore`.

**`.chezmoiignore`**:
Danh sách file/folder bị bỏ qua khi chezmoi sync ra home. Pattern so sánh với đường dẫn đích (`~/docs`), không phải đường dẫn nguồn. Hỗ trợ Go template conditional và `#` comment.

**CachyOS**:
Linux distribution dựa trên Arch, tối ưu hiệu năng. Ship config fish mặc định xung đột với config do chezmoi quản lý; phải bỏ chọn khi cài đặt.

**Limine**:
Bootloader mặc định của CachyOS, dùng cho cả UEFI lẫn legacy BIOS. File boot UEFI nằm ở `\EFI\limine\limine_x64.efi` trên ESP.
_Avoid_: "lumie"

**Boot entry (NVRAM)**:
Mục boot trong firmware UEFI, trỏ tới file `.efi` trên ESP. Khác với chính file bootloader trên ESP: firmware có thể tự xóa boot entry khi thiết bị chứa nó vắng mặt lúc boot, trong khi file vẫn còn nguyên.
_Avoid_: "boot option"

**cachy-chroot**:
Tiện ích trên live ISO CachyOS bọc quanh `arch-chroot`: tự tìm phân vùng, mount root + mọi mountpoint trong `fstab` (hỗ trợ Btrfs/LUKS) rồi chroot vào hệ thống đã cài.

**mangowm**:
Wayland compositor với animation mượt và config modular chia thành các file `cfg/*.conf`. Đóng vai trò window manager. Không có login greeter.

**Noctalia**:
Desktop shell cho Wayland, cung cấp bar, panel, launcher, thông báo, wallpaper, màn hình khóa, và ghi màn hình. Cũng ship **Noctalia Greeter** (qua `noctalia-greeter-session`), màn hình đăng nhập thay thế SDDM.

**Noctalia Greeter**:
Login greeter đi kèm Noctalia; gọi bằng `noctalia-greeter-session`. Được chọn thay SDDM để đồng bộ giao diện với Noctalia desktop shell.

**Stellar** (còn gọi là stella):
Trình quản lý theme cho Starship: tải theme từ stellar hub và áp dụng bằng symlink `~/.config/starship.toml`. Tự sở hữu toàn bộ trạng thái của nó trong `~/.config/stellar/`; chezmoi không quản lý (xem ADR-0002).

**Theme mong muốn**:
Theme + version mà bộ dotfiles này mặc định dùng cho Starship (hiện là `presets/rose-pine-moon@1.0`), khai báo trong README và áp dụng thủ công bằng `stellar apply`.
_Avoid_: "config stellar"

**Cache theme**:
Bản sao theme đã tải từ stellar hub trong `~/.config/stellar/presets/`. Tái tạo được bằng `stellar apply`, không phải nguồn để quản lý.

**Trạng thái cài đặt (stellar)**:
Dữ liệu riêng của từng máy trong `~/.config/stellar/config.json`: `install_id`, hash, đường dẫn tuyệt đối. Không bao giờ đồng bộ giữa các máy.
_Avoid_: "config stellar"

**Starship**:
Prompt đa nền tảng. Cấu hình với bảng màu rose-pine tùy chỉnh và layout segment trong `~/.config/starship.toml` — file này do Stellar sở hữu dưới dạng symlink.

**Ghostty**:
Emulator terminal tăng tốc GPU (thay thế Alacritty). Cấu hình tối giản: font, kiểu cursor.

**Helium**:
Trình duyệt dựa trên Chromium (thay thế Firefox). Chạy dạng AppImage quản lý bởi AppManager. Mã hóa cookie/password qua `os_crypt`, bắt buộc cần Secret Service đang chạy; không có thì reboot là phải login lại dù profile còn nguyên.
_Avoid_: "helium browser chung chung khi đang nói profile `net.imput.helium`"

**Secret Service**:
API D-Bus `org.freedesktop.secrets` để app lưu secret mã hóa. Chỉ một provider giữ tên này tại một thời điểm.
_Avoid_: "keyring chung chung"

**gnome-keyring**:
Provider Secret Service dùng trên mangowm. Chạy qua systemd user socket `gnome-keyring-daemon.socket`, unlock bằng PAM lúc login.
_Avoid_: "kwallet" (stack KDE, không dùng ở đây), "password-store=basic" (không mã hóa, chỉ để test)

**os_crypt**:
Cơ chế Chromium mã hóa cookie/password bằng key trong Secret Service. `Local State` có `os_crypt.encrypted_key` nghĩa là init thành công; `portal.prev_init_success=false` nghĩa là thất bại.
_Avoid_: "cookie bị xóa"

**Zellij**:
Trình quản lý session terminal (tab, pane, layout).

**Fresh**:
Dashboard / trình khởi chạy ứng dụng TUI.

**AppManager**:
Công cụ GUI tích hợp AppImage vào hệ thống (desktop entry, icon). Function fish `appimage_update_icon` sắp xếp icon đã tạo vào `hicolor` và refresh cache GTK/desktop.

**fcitx5-lotus**:
Engine nhập liệu tiếng Việt cho fcitx5. IM mặc định đặt là `lotus` với toggle `Alt+Space`.

**QT_QPA_PLATFORMTHEME**:
Biến môi trường đặt là `qt6ct` trong mangowm `env.conf` để Qt6 app dùng theme qt6ct (bảng màu Noctalia). Cũng set `QT_QPA_PLATFORMTHEME_QT6=qt6ct` cho Qt6 rõ ràng.

**qt6ct / qt5ct**:
Công cụ cấu hình Qt. Cả hai trỏ đến bảng màu Noctalia (`~/.config/qt6ct/colors/noctalia.conf` và `~/.config/qt5ct/colors/noctalia.conf`) để đồng bộ theme.

**cachyos-fish-config**:
Gói `cachyos-fish-config` (CachyOS repo) ship config fish mặc định. bị bỏ qua vì nó override `config.fish` do chezmoi quản lý, cài thêm prompt không mong muốn, và định nghĩa abbreviation/function mâu thuẫn với thiết kế.

**SDDM**:
Simple Desktop Display Manager. Rõ ràng không dùng; thay bằng Noctalia Greeter.

**xdg-desktop-portal**:
Mặt tiền D-Bus điều phối yêu cầu desktop (screencast, screenshot, file chooser) tới backend phù hợp. Cấu hình qua `mango-portals.conf`.
_Avoid_: gọi chung là "portal" khi đang nói tới backend cụ thể.

**portal backend**:
Daemon D-Bus thực thi một nhóm portal interface cho một họ compositor. Ví dụ `xdg-desktop-portal-wlr` cho wlroots/mango, `xdg-desktop-portal-gtk` cho file chooser, `xdg-desktop-portal-kde` cho Plasma.
_Avoid_: "lib", "portal" chung chung.

**picker**:
Tool chọn nguồn share được portal backend gọi hộ khi app xin screencast. `slurp` chọn màn hình/vùng, `fuzzel`/`wofi`/`rofi` chọn theo danh sách window/output.
_Avoid_: "lib".

**tool (trong check_tools)**:
Binary người dùng gõ trực tiếp được trên terminal (`type -q` thấy). Daemon portal trong `/usr/lib` hay `/usr/libexec` không phải tool theo nghĩa này.
_Avoid_: nhét daemon D-Bus vào check_tools.

**lib**:
Chỉ file thư viện `.so` mà binary link tới. Không dùng cho daemon hay picker.
_Avoid_: "lib portal", "lib picker".

**LocalSend**:
Công cụ chuyển file qua mạng local. Cần rule firewall `ufw` để cho phép kết nối đến.

**Koonde + Proton Pass**:
Đồng bộ dữ liệu web (bookmark, mật khẩu, v.v.).

**Ante**:
AI agent dùng cho workflow phát triển.

**lazygit**:
TUI cho git. Tích hợp với Ante qua custom command menu (`Ctrl+A`): gen commit message từ staged diff rồi commit trực tiếp, push, copy clipboard, hoặc undo. Script bridge `~/.local/bin/lazygit-generate-msg` nhận mode flag, fish function `lazygit_generate_msg` delegate tới script đó.

**fzf / zoxide / eza / tealdeer / bat**:
CLI tiện ích: fuzzy finder, nhảy thư mục, ls thay thế hiện đại, tóm tắt man page, cat với syntax highlighting.

**fastfetch**:
Công cụ hiển thị thông tin hệ thống khi mở shell (thay thế neofetch, nhanh hơn). Dùng preset `examples/12.jsonc` (tên preset, không cần đường dẫn đầy đủ). Chạy khi interactive session bắt đầu.

**full experience (cursor)**:
Bốn deps để plugin Cursor `vn1k/cursor` dùng hết tính năng theo doc của nó: `win2xcur` (preview, import pack Windows `.cur`/`.ani`, build theme), `python-wand` (resize/render ảnh), `imagemagick` (lib mà `wand` bind tới), `zenity` (nút Folder… browse). Kiểm tra bằng `check_cursor_stack`.
_Avoid_: "cài full cursor" (không rõ gồm những gì)

**minimal (cursor)**:
Chỉ `python3` (engine `bin/curmgr.py` đi kèm plugin). Đủ để list và apply theme; import/build báo thiếu thay vì fail giữa chừng, thiếu `zenity` thì gõ path tay.
_Avoid_: "cursor cơ bản"

**cursor layer**:
Một trong 6 nơi plugin Cursor `vn1k/cursor` đồng bộ theme về: compositor (`cursor.conf`), `gsettings`, `gtk3`, `gtk4`, `xdg_default` (`~/.icons/default`), `environment` (`90-xcursor.conf`).
_Avoid_: "theme" chung chung khi đang nói cursor

**consistent (cursor)**:
`curmgr.py current` báo `true` khi cả 6 cursor layer cùng một theme và không lớp nào trống. Panel báo drift khi ngược lại.
_Avoid_: "đồng bộ" chung chung

**cursor.conf (mango)**:
File cursor của Mango do plugin own, không do chezmoi quản lý. `appearance.conf` không giữ `cursor_theme`/`cursor_size` để tránh 2 nguồn truth; `config.conf` chèn `source=` tới file này bằng template `homeDir` cho portable đa username.

---
_Nên tránh_: "Alacritty" (đã thay bằng Ghostty), "Firefox" (đã thay bằng Helium), "SDDM" (đã thay bằng Noctalia Greeter), "cachyos-fish-config" (xung đột với chezmoi).
