function t --description 'tmux attach or new'
    set -l session main
    test (count $argv) -gt 0; and set session $argv[1]
    tmux attach -t $session; or tmux new-session -s $session
end
