# Không dùng biến BROWSER, dùng MIME default cho Helium

Trên mangowm, link được mở bởi `xdg-open` (xdg-utils chạy generic vì `XDG_CURRENT_DESKTOP=mango`), nên nguồn truth phải là `[Default Applications]` trong `~/.config/mimeapps.list` trỏ tới một desktop entry hợp lệ. Biến `BROWSER` bị bỏ: `xdg-settings` ưu tiên nó (khiến `get` trả desktop entry của Gemini PWA) và chặn hoàn toàn lệnh `set`.

**Considered options**

- Giữ `BROWSER=helium` ở cả `env.conf` lẫn `config.fish`: dễ nhưng tạo default giả, block `xdg-settings`, và vẫn thua khi browser khác xuất hiện trong `mimeinfo.cache` — chính là lỗi đã gặp khi cài Firefox.
- Dùng `gio mime` để đặt default: GLib chấp nhận `helium.desktop` của AppManager dù `Exec` có dấu nháy, nhưng `xdg-open` thì loại entry đó → hai nửa hệ thống trả hai answer khác nhau.
- Sửa trực tiếp `helium.desktop` do AppManager sinh: bị ghi đè mỗi lần update AppImage.
- Bỏ `BROWSER`, thêm `helium-browser.desktop` do chezmoi owns (`Exec=helium %U`) + script `run_once_` ghi 3 key MIME: **chọn**. Stable, portable, không đụng file của AppManager, không cần enforcer lúc login.

**Consequences**

- `xdg-settings get/check/set default-web-browser` hoạt động bình thường trở lại.
- `mimeapps.list` không do chezmoi owns; chỉ 3 key browser được ghi một lần, association của app khác vẫn do app đó quản lý.
- Lỗi thượng nguồn vẫn còn ở AppManager 3.8.0 (đã báo [kem-a/AppManager#237](https://github.com/kem-a/AppManager/issues/237)); entry `helium.desktop` của nó vẫn không dùng làm MIME default được.
