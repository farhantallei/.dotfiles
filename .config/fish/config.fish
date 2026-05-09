set -g fish_greeting ""

if status --is-login
    if type -q fastfetch
        fastfetch
    end
end
