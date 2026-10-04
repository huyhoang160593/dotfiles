# Helium dùng gnome-keyring làm Secret Service, auto-unlock qua greetd PAM

Helium (Chromium AppImage, profile `~/.config/net.imput.helium/`) mất login sau reboot vì không có `org.freedesktop.secrets`: `gnome-keyring-daemon.{service,socket}` bị mask về `/dev/null`, D-Bus overrides `ExecStart=/bin/false`, autostart `Hidden=true`, nên `Local State` thiếu `os_crypt.encrypted_key` (`portal.prev_init_success=false`). Quyết định bật lại gnome-keyring (systemd socket + `exec-once` trong mangowm `autostart.conf`) và auto-unlock qua `/etc/pam.d/greetd`.

## Considered Options

| Lựa chọn | Bỏ qua vì |
|---|---|
| kwallet | kéo stack KDE, mango không dùng; gnome-keyring nhẹ và đúng chuẩn Chromium |
| `--password-store=basic` | không mã hóa, secret nằm plaintext; chỉ để test |
| unlock tay | mỗi login phải nhập thêm mật keyring, dễ quên và tưởng là lại lỗi |

## Consequences

- `/etc/pam.d/greetd` cần 2 dòng `pam_gnome_keyring.so` (auth + session `auto_start`); file này ngoài chezmoi, phải sửa bằng sudo tay.
- Mật khẩu keyring `Default.keyring` phải trùng mật login mới auto-unlock; nếu lệch thì xóa `~/.local/share/keyrings/Default.keyring` cho tạo lại ở login tới, hoặc đổi bằng `seahorse`.
- Helium phải login lại một lần cuối sau fix để cookie được mã hóa lại bằng key mới.
