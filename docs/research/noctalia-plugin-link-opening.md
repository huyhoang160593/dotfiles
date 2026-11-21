# Mở link từ Noctalia và default browser

Ghi chép điều tra về việc click link (vd Settings → Plugins của Noctalia) đôi khi không mở đúng Helium.

## Đường đi của một link

Trên mangowm, `XDG_CURRENT_DESKTOP=mango` không khớp handler nào của xdg-utils 1.2.1 → `xdg-open` chạy generic:

1. `open_generic_xdg_x_scheme_handler` → `xdg-mime query default x-scheme-handler/<scheme>`.
2. `xdg-mime` đọc `[Default Applications]` trong `~/.config/mimeapps.list`, validate desktop file bằng `command -v <exec-first-word>`, rồi mới fallback sang `defaults.list`/`mimeinfo.cache`.
3. Biến `BROWSER` (`open_envvar`) chỉ được xét **sau khi** path MIME thất bại.

Vì vậy `BROWSER=helium` không quyết định link mở bằng gì trên máy này.

## Tại sao "tưởng là helium mà ra firefox"

AppManager 3.8.0 sinh `helium.desktop` với `Exec="/home/.../Applications/Helium" %U`. Dấu nháy nằm trong token đầu → `command -v` fail → `xdg-mime` loại entry, mọi default trỏ tới `helium.desktop` bị bỏ qua. Trước khi cài Firefox, link vẫn mở Helium chỉ vì fallback `mimeinfo.cache` của user ghi helium trước cache hệ thống. Sau khi cài Firefox, `update-desktop-database` regenerate cache hệ thống, thêm `firefox.desktop` → fallback trả Firefox **mà không cần ai bấm "Make Default"**.

Bug thượng nguồn: [kem-a/AppManager#237](https://github.com/kem-a/AppManager/issues/237).

## Tác dụng phụ của `BROWSER`

`xdg-settings` lại ưu tiên `$BROWSER` ở chiều ngược lại:

- `xdg-settings get default-web-browser` → `chrome-...-Default.desktop` (Gemini PWA, cùng binary Helium) vì `binary_to_desktop_file` chọn desktop entry có `Exec` không nháy đầu tiên.
- `xdg-settings set default-web-browser ...` → từ chối: `$BROWSER is set and can't be changed with xdg-settings`.

## Giải pháp

Xem [ADR-0005](../adr/0005-khong-dung-bien-BROWSER.md): bỏ `BROWSER`, dùng desktop entry `helium-browser.desktop` với `Exec=helium %U` và 3 key MIME tường minh. Không cần script chạy mỗi login.

## Verify

```sh
xdg-mime query default x-scheme-handler/http
xdg-mime query default x-scheme-handler/https
xdg-mime query default text/html
env -u BROWSER xdg-settings get default-web-browser
env -u BROWSER xdg-settings check default-web-browser helium-browser.desktop
```
