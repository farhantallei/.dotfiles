set -gx EDITOR nvim
set -gx VISUAL nvim

set -gx BUN_INSTALL $HOME/.bun
set -gx GOPATH $HOME/go

set -l __tcltk_lib /opt/homebrew/opt/tcl-tk/lib
if test -d $__tcltk_lib
    set -l __tcl_dir (command find $__tcltk_lib -maxdepth 1 -type d -name 'tcl[0-9]*' 2>/dev/null | sort -V | tail -n1)
    if test -n "$__tcl_dir"
        set -gx TCL_LIBRARY $__tcl_dir
        set -gx TK_LIBRARY $__tcl_dir
    end
end
