function Z --description 'yazi cd integration, auto-trigger zoxide picker on launch'
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    set -lx YAZI_AUTO_ZOXIDE 1
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and test "$cwd" != "$PWD"; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
