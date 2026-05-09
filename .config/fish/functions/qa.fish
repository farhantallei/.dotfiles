function qa --description 'kill tmux server and exit'
    if set -q TMUX
        tmux kill-server
    end
    exit
end
