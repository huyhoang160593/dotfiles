#!/bin/sh
# Ghi 3 key MIME default cho Helium — chạy đúng một lần sau `chezmoi apply`.
# Dùng desktop entry do chezmoi owns (Exec=helium %U) thay vì helium.desktop
# của AppManager: entry đó có Exec bị nháy nên xdg-utils loại (kem-a/AppManager#237).
command -v helium >/dev/null 2>&1 || exit 0

xdg-mime default helium-browser.desktop \
  x-scheme-handler/http \
  x-scheme-handler/https \
  text/html
