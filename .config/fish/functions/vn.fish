function vn --description 'edit nvim config'
    if test (count $argv) -eq 0
        nvim ~/.config/nvim
    else
        nvim ~/.config/nvim/$argv
    end
end
