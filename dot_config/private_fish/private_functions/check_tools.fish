function check_tools --description 'Kiểm tra các tool cần thiết đã cài đặt chưa'
    set tools \
        "ghostty:Ghostty (terminal - AppImage)" \
        "helium:Helium (browser - AppImage)" \
        "fish:Fish (shell)" \
        "starship:Starship (prompt)" \
        "stellar:Stellar (quản lý theme)" \
        "noctalia:Noctalia (desktop shell)" \
        "fresh:Fresh (TUI dashboard)" \
        "zellij:Zellij (session manager)" \
        "ante:Ante (AI agent)" \
        "appimage_update_icon:AppManager (icon fix)" \
        "chezmoi:chezmoi (dotfile manager)" \
        "ufw:ufw (firewall)" \
        "fzf:fzf (fuzzy finder)" \
        "zoxide:zoxide (dir jumper)" \
        "eza:eza (ls replacement)" \
        "tldr:tealdeer (tldr client)" \
        "bat:bat (cat replacement)" \
        "lazygit:lazygit (git TUI)"

    set missing
    set found 0
    set total (count $tools)

    for entry in $tools
        set parts (string split ":" $entry)
        set cmd $parts[1]
        set label $parts[2]

        if type -q $cmd
            set found (math $found + 1)
        else
            set -a missing "$label (`$cmd`)"
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
