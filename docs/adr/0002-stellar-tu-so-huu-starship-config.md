---
status: accepted
date: 2026-09-28
---

# Stellar tự sở hữu starship config; chezmoi không quản lý

Chezmoi **không** quản lý `~/.config/starship.toml` lẫn bất kỳ file nào trong `~/.config/stellar/`. Stellar tự sở hữu symlink `starship.toml`, cache theme, và trạng thái cài đặt của nó. Theme mong muốn (`presets/rose-pine-moon@1.0`) được khai báo trong README và áp dụng thủ công bằng `stellar apply`; `check_tools` đóng vai trò cảnh báo khi thiếu.

## Lý do

Trước đây repo quản lý `dot_config/stellar/config.json`, `dot_config/stellar/presets/*.toml` và symlink `dot_config/symlink_starship.toml`. Việc này hỏng khi sync sang máy khác vì trộn lẫn ba loại trạng thái khác nhau:

1. **`config.json` là trạng thái máy, không phải config**: chứa `install_id` (định danh mỗi lần cài đặt), `applied_hash`, và đường dẫn tuyệt đối `/home/<username>/...`. Nhân bản sang máy khác làm sai identity và trỏ đường dẫn sai.
2. **`presets/*.toml` là cache**: tải lại được từ stellar hub (`stellar apply presets/<theme>@<version>`), không phải nguồn để quản lý.
3. **Hai writer cùng sở hữu một file**: `stellar apply` tự tạo/cập nhật symlink `~/.config/starship.toml` và ghi hash vào `config.json`; chezmoi apply sẽ ghi đè trạng thái của stellar (đổi theme qua `stellar apply` bị lôi về theme cũ, hash lệch, rollback sai).

Đồng thời symlink hardcode `/home/the99spuppycat/...` treo trên mọi máy có username/`$HOME` khác, và cache chưa tồn tại trên máy mới khiến `starship.toml` trỏ vào file không có — prompt hỏng hẳn.

## Các lựa chọn đã cân nhắc

| Lựa chọn | Bỏ qua vì |
|---|---|
| Chezmoi sở hữu symlink (template `{{ .chezmoi.homeDir }}`) + vendor cache | Vẫn hai writer; mọi lần đổi theme phải đi qua git; cache trùng lặp |
| `run_once_after_` script bootstrap `stellar apply` | Chezmoi vẫn phải biết theme identity; chấp nhận được nhưng thừa — `check_tools` + README đủ để máy mới tự chạy một lệnh |
| Chỉ xoá `config.json`, giữ cache + symlink | Vẫn còn path tuyệt đối và phụ thuộc cache cục bộ |

## Hệ quả

- Máy mới sẽ hiển thị prompt mặc định cho tới khi tự chạy `stellar apply presets/rose-pine-moon@1.0` (theme hiện tại — cập nhật trong README nếu đổi).
- Đổi theme không đi qua git: mỗi máy có thể dùng theme khác nhau tùy thích.
- `install_id`/hash mỗi máy tự giữ, không bao giờ bị nhân bản.
- `.chezmoiignore.tmpl` liệt kê `.config/starship.toml` và `.config/stellar` để `chezmoi add` không bắt lại.
- `check_tools` báo thiếu khi binary `stellar` cài rồi nhưng `~/.config/starship.toml` chưa tồn tại.

## Xem thêm

- `CONTEXT.md` — glossary: theme mong muốn, cache theme, trạng thái cài đặt
- `README.md` — mục "Starship hiển thị prompt mặc định"
- `dot_config/private_fish/private_functions/check_tools.fish` — cảnh báo thiếu theme
