function __fish_apply_catppuccin
    set -l variant $__theme_variant
    switch $variant
        case mocha macchiato frappe latte
        case '*'
            set variant mocha
    end

    set -l palette
    for line in (__fish_palette $variant)
        set -a palette $line
    end

    function __pal --no-scope-shadowing
        for entry in $palette
            set -l kv (string split -m 1 = $entry)
            if test "$kv[1]" = "$argv[1]"
                echo $kv[2]
                return
            end
        end
    end

    set -U fish_color_normal      (__pal text)
    set -U fish_color_command     (__pal blue)
    set -U fish_color_keyword     (__pal mauve)
    set -U fish_color_quote       (__pal green)
    set -U fish_color_redirection (__pal pink)
    set -U fish_color_end         (__pal peach)
    set -U fish_color_error       (__pal red)
    set -U fish_color_param       (__pal flamingo)
    set -U fish_color_comment     (__pal overlay2)
    set -U fish_color_selection   --background=(__pal surface0)
    set -U fish_color_search_match --background=(__pal surface0)
    set -U fish_color_operator    (__pal sky)
    set -U fish_color_escape      (__pal pink)
    set -U fish_color_autosuggestion (__pal overlay0)
    set -U fish_color_cancel      (__pal red)
    set -U fish_color_option      (__pal yellow)
    set -U fish_color_user        (__pal teal)
    set -U fish_color_host        (__pal blue)
    set -U fish_color_host_remote (__pal yellow)
    set -U fish_color_status      (__pal red)
    set -U fish_color_cwd         (__pal yellow)
    set -U fish_color_cwd_root    (__pal red)
    set -U fish_color_valid_path  --underline

    set -U fish_pager_color_progress       (__pal overlay0)
    set -U fish_pager_color_prefix         (__pal sky) --bold
    set -U fish_pager_color_completion     (__pal text)
    set -U fish_pager_color_description    (__pal overlay0) --italics
    set -U fish_pager_color_selected_background --background=(__pal surface0)

    functions -e __pal
end

if not set -q __theme_variant
    set -l v mocha
    if test -r $HOME/.config/theme-current
        set v (string trim < $HOME/.config/theme-current)
    end
    switch $v
        case mocha macchiato frappe latte
        case '*'
            set v mocha
    end
    set -U __theme_variant $v
end

__fish_apply_catppuccin

function __fish_theme_handler --on-variable __theme_variant
    __fish_apply_catppuccin
end
