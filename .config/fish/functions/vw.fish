function vw --description 'edit wezterm config'
    if test (count $argv) -eq 0
        nvim ~/.config/wezterm
    else
        nvim ~/.config/wezterm/$argv
    end
end
