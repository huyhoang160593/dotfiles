function appimage_update_icon --description 'Sắp xếp icon từ AppImage về thư mục hicolor và cập nhật cache hệ thống'
    set -l base_icons "$HOME/.local/share/icons"
    set -l target_dir "$base_icons/hicolor/256x256/apps"
    set -l apps_dir "$HOME/.local/share/applications"

    # Color helpers
    set -l c_green (set_color green)
    set -l c_yellow (set_color yellow)
    set -l c_cyan (set_color cyan)
    set -l c_reset (set_color normal)

    # 1. Create hicolor app directory
    mkdir -p "$target_dir"

    # 2. Check and copy standalone PNG files
    set -l png_files (path filter -f "$base_icons"/*.png)
    if test (count $png_files) -gt 0
        mv $png_files "$target_dir/"
        echo -e "[$c_green OK $c_reset] Copied $c_cyan"(count $png_files)"$c_reset icon(s) to $target_dir"
    else
        echo -e "[$c_yellow SKIP $c_reset] No standalone .png files found in $base_icons"
    end

    # 3. Rebuild system caches
    if type -q gtk-update-icon-cache
        gtk-update-icon-cache -f -t "$base_icons/hicolor" 2>/dev/null
        echo -e "[$c_green OK $c_reset] GTK icon cache updated."
    else
        echo -e "[$c_yellow WARN $c_reset] gtk-update-icon-cache binary not found."
    end

    if type -q update-desktop-database
        update-desktop-database "$apps_dir"
        echo -e "[$c_green OK $c_reset] Desktop database updated."
    else
        echo -e "[$c_yellow WARN $c_reset] update-desktop-database binary not found."
    end
end
