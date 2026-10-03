function check_cursor_stack --description 'Kiểm tra deps full experience của plugin Cursor vn1k/cursor (list/apply chỉ cần python3; import/build cần win2xcur+wand; browse cần zenity)'
    # PM detection (Arch + Fedora, mirror check_mango_stack)
    if type -q pacman
        set pm pacman
    else if type -q dnf
        set pm dnf
    else
        set pm none
    end

    # 1. System packages theo PM (doc Cursor: Arch pacman/yay, Fedora dnf/pip)
    if test "$pm" = "pacman"
        set pkgs \
            "python-wand:resize/render cursor (python-wand)" \
            "imagemagick:thư viện ảnh cho wand" \
            "zenity:nút Folder… browse"
    else if test "$pm" = "dnf"
        set pkgs \
            "python3-wand:resize/render cursor (python3-wand)" \
            "ImageMagick:thư viện ảnh cho wand" \
            "zenity:nút Folder… browse"
    else
        set pkgs
    end

    set missing_pkgs
    for entry in $pkgs
        set parts (string split ":" $entry)
        set pkg $parts[1]
        set label $parts[2]
        set ok 0
        if test "$pm" = "pacman"
            if pacman -Q $pkg >/dev/null 2>&1
                set ok 1
            end
        else if test "$pm" = "dnf"
            if rpm -q $pkg >/dev/null 2>&1
                set ok 1
            end
        end
        if test $ok -eq 0
            if test "$pm" = "pacman"
                set -a missing_pkgs "$pkg ($label — `sudo pacman -S $pkg`)"
            else
                set -a missing_pkgs "$pkg ($label — `sudo dnf install $pkg`)"
            end
        end
    end

    # 2. Python libs bằng system python3 (doc bắt buộc importable by system python3)
    set syspy /usr/bin/python3
    set missing_py
    if not test -x $syspy
        set -a missing_py "python3 (không thấy /usr/bin/python3)"
    else
        if not $syspy -c "import wand" >/dev/null 2>&1
            if test "$pm" = "pacman"
                set -a missing_py "wand (python-wand — `sudo pacman -S python-wand`)"
            else
                set -a missing_py "wand (python3-wand — `sudo dnf install python3-wand`)"
            end
        end
        if not $syspy -c "import win2xcur" >/dev/null 2>&1
            # Chuỗi cài win2xcur: yay -> paru -> pip (Arch); pip --user (Fedora)
            set win_hint ""
            if test "$pm" = "pacman"
                if type -q yay
                    set win_hint "yay -S win2xcur"
                else if type -q paru
                    set win_hint "paru -S win2xcur"
                else
                    set win_hint "pip install --user win2xcur"
                end
                set -a missing_py "win2xcur (preview/import/build — `$win_hint`)"
            else
                set -a missing_py "win2xcur (preview/import/build — `pip install --user win2xcur`)"
            end
        end
    end

    # 3. Report (idiom check_mango_stack: mỗi dòng thiếu kèm fix cmd)
    if test (count $missing_pkgs) -eq 0; and test (count $missing_py) -eq 0
        echo "Cursor: đủ full experience (python3 + win2xcur + wand + zenity)"
    else
        echo "Cursor thiếu (mở lại panel sau khi cài):"
        for m in $missing_pkgs
            echo "  - $m"
        end
        for m in $missing_py
            echo "  - $m"
        end
        echo ""
        echo "Check của doc: `/usr/bin/python3 -c \"import win2xcur, wand; print('ok')\"`"
    end
end
