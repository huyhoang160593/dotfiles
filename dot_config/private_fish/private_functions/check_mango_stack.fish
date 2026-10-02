function check_mango_stack --description 'Kiểm tra stack mango: portal đã cài và service có chạy không (.conf do chezmoi sở hữu)'
    set pkgs \
        "xdg-desktop-portal:portal chính" \
        "xdg-desktop-portal-wlr:portal cho mango/wlroots" \
        "xdg-desktop-portal-gtk:file picker"

    set units pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr

    if type -q pacman
        set pm pacman
        set install_hint "sudo pacman -S"
    else if type -q dnf
        set pm dnf
        set install_hint "sudo dnf install"
    else
        set pm none
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
        else
            if test -x /usr/lib/$pkg; or test -x /usr/libexec/$pkg
                set ok 1
            end
        end
        if test $ok -eq 0
            set -a missing_pkgs "$pkg ($label — `$install_hint $pkg`)"
        end
    end

    set dead_units
    for u in $units
        if not systemctl --user is-active --quiet $u 2>/dev/null
            set -a dead_units $u
        end
    end

    if test (count $missing_pkgs) -eq 0
        echo "Portal: đủ 3/3 package"
    else
        echo "Portal thiếu:"
        for m in $missing_pkgs
            echo "  - $m"
        end
    end
    echo ""
    if test (count $dead_units) -eq 0
        echo "Service: chạy đủ (pipewire, wireplumber, portal, portal-wlr)"
    else
        echo "Service chưa chạy:"
        for u in $dead_units
            echo "  - $u (`systemctl --user enable --now $u`)"
        end
    end
    echo ""
    echo ".conf do chezmoi sở hữu: `chezmoi status` sạch là đồng bộ."
end
