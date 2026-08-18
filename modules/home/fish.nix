{ pkgs, vars, ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      ll      = "ls -lahF --color=auto";
      la      = "ls -A --color=auto";
      grep    = "grep --color=auto";
      cls     = "clear";
      sos     = "source";
      py      = "python3";
      flakeup = "nix flake update";
      gc      = "nix-collect-garbage -d";
      gens    = "home-manager generations";
    };

    interactiveShellInit = ''
      set -g fish_greeting

      fish_add_path $HOME/.local/bin

      fish_vi_key_bindings

      function fish_user_key_bindings
        for mode in insert default
          bind -M $mode ctrl-backspace backward-kill-word
          bind -M $mode ctrl-z undo
          bind -M $mode ctrl-b beginning-of-line
          bind -M $mode ctrl-e end-of-line
        end
        bind -M insert up   history-prefix-search-backward
        bind -M insert down history-prefix-search-forward
        bind -M default up   history-prefix-search-backward
        bind -M default down history-prefix-search-forward
      end

      set fish_cursor_default     block
      set fish_cursor_insert      line
      set fish_cursor_replace_one underscore
      set fish_cursor_visual      block

      set -g fish_color_autosuggestion brblack
      set -g fish_color_command        blue
      set -g fish_color_error          red
      set -g fish_color_param          normal
      set -g fish_color_search_match   --background=normal
    '';

    functions = {
      # 系統層套件（dnf 管）的更新，取代 nixos-rebuild
      update = ''
        sudo dnf upgrade --refresh $argv
      '';

      # 使用者層（home-manager）的更新
      hm = ''
        set -l flake_path $argv[1]
        if test -z "$flake_path"
          set flake_path .
        end
        home-manager switch --flake $flake_path#${vars.username}@${vars.hostname} $argv[2..]
      '';

      fish_prompt = ''
        set_color green
        echo -n (whoami)@(hostname)
        set_color normal
        echo -n ':'
        set_color blue
        echo -n (prompt_pwd)
        set_color normal
        echo -n '$ '
      '';

      fm = ''
        set -l tmp (mktemp -t "yazi-cwd.XXXXX")
        yazi $argv --cwd-file $tmp
        set -l cwd (cat $tmp)
        if test -n "$cwd" -a "$cwd" != "$PWD"
          cd $cwd
        end
        rm -f $tmp
      '';
    };
  };
}
