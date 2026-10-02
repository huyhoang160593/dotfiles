function check_tools --description 'Kiểm tra các tool cần thiết đã cài đặt chưa'
    set tools \
        "ghostty:Ghostty (terminal - AppImage)" \
        "helium:Helium (browser - AppImage)" \
        "fish:Fish (shell)" \
        "starship:Starship (prompt)" \
        "stellar:Stellar (quản lý theme)" \
        "fresh:Fresh (TUI dashboard)" \
        "zellij:Zellij (session manager)" \
        "ante:Ante (AI agent)" \
        "appimage_update_icon:AppManager (icon fix)" \
        "chezmoi:chezmoi (dotfile manager)" \
        "mise:mise (runtime manager)" \
        "ufw:ufw (firewall)" \
        "fzf:fzf (fuzzy finder)" \
        "zoxide:zoxide (dir jumper)" \
        "eza:eza (ls replacement)" \
        "tldr:tealdeer (tldr client)" \
        "bat:bat (cat replacement)" \
        "lazygit:lazygit (git TUI)" \
        "fastfetch:fastfetch (system info)" \
        "spf:superfile (TUI file manager)" \
        "gpu-screen-recorder:gpu-screen-recorder (screen recorder)" \
        "easyeffects:EasyEffects (audio effects)" \
        "mime-tui:mime-tui (quản lý MIME type → ứng dụng)" \
        "mango:Mango (compositor)" \
        "mmsg:mmsg (mango IPC)" \
        "pipewire:PipeWire (screen share backend)" \
        "wireplumber:WirePlumber (pipewire session manager)" \
        "grim:grim (screenshot backend)" \
        "slurp:slurp (chọn màn hình)" \
        "fuzzel:fuzzel (chọn window)"

    set missing
    set found 0
    set total (count $tools)

    for entry in $tools
        set parts (string split ":" $entry)
        set cmd $parts[1]
        set label $parts[2]

        if not type -q $cmd
            set -a missing "$label (`$cmd`)"
        else if test "$cmd" = "stellar"; and not test -e ~/.config/starship.toml
            # Binary có nhưng chưa apply theme nào cũng coi là thiếu
            set -a missing "$label (đã cài, chưa apply theme — `stellar apply presets/rose-pine-moon@1.0`)"
        else
            set found (math $found + 1)
        end
    end

    echo "Đã tìm thấy $found/$total tool"
    echo ""

    if test (count $missing) -gt 0
        echo "Cần cài đặt:"
        for m in $missing
            echo "  - $m"
        end
    else
        echo "Tất cả tool đã sẵn sàng!"
    end
end
