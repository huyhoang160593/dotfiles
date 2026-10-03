---
status: accepted
date: 2026-10-03
---

# Check Cursor bằng file riêng, chỉ cover Arch + Fedora

`check_cursor_stack.fish` là file riêng, không nhét vào `check_tools` hay `check_mango_stack`. Nó check 4 deps full experience của plugin Cursor `vn1k/cursor` (`win2xcur`, `python-wand`, `imagemagick`, `zenity`) trên đúng hai PM Arch (`pacman`) và Fedora (`dnf`); mỗi dòng thiếu kèm fix cmd của PM đó. Python lib check bằng `/usr/bin/python3 -c "import ..."`, tách riêng `wand` và `win2xcur`. Hint cài `win2xcur` trên Arch theo chuỗi `yay` → `paru` → `pip install --user`.

## Lý do

Doc Cursor chia ba tầng tính năng với ba loại check khác nhau: package hệ thống (`pacman -Q`/`rpm -q`), binary (`zenity`), và python lib (`python3 -c import`) — mà repo chưa từng có tiền lệ check python lib. Nhét vào `check_tools` sẽ vỡ định nghĩa scope của nó trong CONTEXT.md (chỉ binary user gõ tay, daemon còn bị cấm nữa là lib). Nhét vào `check_mango_stack` cũng sai vì file đó là portal + service của Mango, còn cursor chỉ liên quan tới Mango ở một dòng `mmsg reload`.

Pin `/usr/bin/python3` thay vì `python3` trên PATH vì doc bắt buộc "importable by the system `python3`", mà PATH của repo có mise shims đứng trước `/usr/bin`. Tách hai import riêng để biết thiếu cái nào (check gộp của doc dừng ở module đầu tiên fail).

Chỉ cover Arch + Fedora vì đó là hai môi trường đang dùng; Debian/Ubuntu cần thêm nhánh `apt` (`dpkg -s`) và flag `--break-system-packages` của pip — để dành khi nào có máy thứ ba.

## Các lựa chọn đã cân nhắc

| Lựa chọn | Bỏ qua vì |
|---|---|
| Nhét vào `check_tools` | Vỡ scope "binary user gõ"; chưa có idiom check python lib |
| Nhét vào `check_mango_stack` | File đó là portal + service; cursor chỉ ké một dòng `mmsg` |
| Cover luôn Debian/Ubuntu (`apt`) | Chưa có máy để kiểm chứng hint; doc Debian cần flag pip riêng |
| Check `python3` trên PATH thay vì `/usr/bin/python3` | Sai lệch khi mise shims override; doc yêu cầu system python |

## Hệ quả

- Máy mới chạy `check_cursor_stack` sẽ thấy đúng 4 dòng thiếu kèm lệnh cài của PM nó đang dùng.
- Thêm PM mới (vd `apt`) thì sửa một file duy nhất này.
- `CONTEXT.md` — glossary: full experience (cursor), minimal (cursor)

## Xem thêm

- `CONTEXT.md` — glossary: full experience (cursor), minimal (cursor)
- `README.md` — bảng Fish custom functions: `check_cursor_stack`, `check_mango_stack`
- `dot_config/private_fish/private_functions/check_cursor_stack.fish`
