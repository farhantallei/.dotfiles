function vf --description 'edit fish config'
    if test (count $argv) -eq 0
        nvim ~/.config/fish
    else
        nvim ~/.config/fish/$argv
    end
end
