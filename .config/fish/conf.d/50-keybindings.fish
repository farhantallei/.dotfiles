status --is-interactive; or exit 0

function fish_user_key_bindings
    bind \eb backward-word
    bind \ef forward-word
    bind \e\[A history-search-backward
    bind \e\[B history-search-forward
end
