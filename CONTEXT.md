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
Trình quản lý theme cho Starship. Lưu theme preset đang dùng (ví dụ: `presets/rose-pine@1.0`) và áp dụng lên `~/.config/starship.toml` qua CLI `stellar`.

**Starship**:
Prompt đa nền tảng. Cấu hình với bảng màu rose-pine tùy chỉnh và layout segment trong `~/.config/starship.toml`.

**Ghostty**:
Emulator terminal tăng tốc GPU (thay thế Alacritty). Cấu hình tối giản: font, kiểu cursor.

**Helium**:
Trình duyệt dựa trên Chromium (thay thế Firefox). Chạy dạng AppImage quản lý bởi AppManager.

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
Portal implementation cho Wayland. Cấu hình qua `mango-portals.conf` dùng `wlr` cho screencast/screenshot và `gnome-keyring` cho secrets.

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

---
_Nên tránh_: "Alacritty" (đã thay bằng Ghostty), "Firefox" (đã thay bằng Helium), "SDDM" (đã thay bằng Noctalia Greeter), "cachyos-fish-config" (xung đột với chezmoi).
