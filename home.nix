{
  config,
  noctalia ? null,
  pkgs,
  ...
}:
{
  imports = [
    noctalia.homeModules.default
  ];

  home = {
    username = "colino";
    homeDirectory = "/home/colino";
    stateVersion = "25.11";

    file = {
      ".p10k.zsh".source = ./config/p10k.zsh;
      ".ideavimrc".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Dotfiles/config/ideavimrc";
    };

    packages = with pkgs; [
      gitflow
      localsend
      omnisharp-roslyn
      pyright
      rust-analyzer
      statix
      zsh-powerlevel10k
    ];

    sessionVariables = {
    };

    file.bin.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Dotfiles/bin";
  };

  xdg = {
    configFile = {
      project-launcher.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Dotfiles/config/project-launcher";

      "niri/config.kdl".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Dotfiles/config/niri/config.kdl";

      nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Dotfiles/config/nvim";
    };
  };

  programs = {
    noctalia-shell = {
      enable = true;
    };

    bash.enable = true;

    zsh = {
      enable = true;

      # Optional but recommended quality-of-life
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        "ls" = "eza --icons --long --header --color=always";
        "lss" = "ls --total-size --sort=size";
        "ll" = "ls";
        "l" = "ll";
        "la" = "l -A";

        "vrc" = "zsh -c 'cd ~/Dotfiles; vi configuration.nix'";
        "vrcp" = "zsh -c 'cd ~/Dotfiles; vi modules/systemPackages.nix'";
        "src" = "zsh -c '~/bin/nrs' && source ~/.zshrc";
        "vrh" = "zsh -c 'cd ~/Dotfiles; vi home.nix'";
        "srh" = "zsh -c 'cd ~/Dotfiles; home-manager switch --flake .' && source ~/.zshrc";
        "rc" = "source ~/.zshrc";

        "lg" = "lazygit";
        "ld" = "lazydocker";

        "dc" = "docker compose";
        "nd" = "nix develop .";
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "docker"
          "python"
          "pip"
          "sudo"
        ];
        theme = "";
      };

      initContent = ''
        if [[ -n "$IN_NIX_SHELL" ]]; then
          typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true
        fi

        # Powerlevel10k (theme)
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

        # If you have a p10k config file, load it
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

        function ww() {
            local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
            command yazi "$@" --cwd-file="$tmp"
            IFS= read -r -d "" cwd < "$tmp"
            [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
            rm -f -- "$tmp"
        }

        export LESS="-R --mouse --wheel-lines=3"
        export PAGER="less"

        export PATH="$HOME/bin:$PATH"

        # export ANTHROPIC_AUTH_TOKEN="ollama"
        # export ANTHROPIC_API_KEY=""
        # export ANTHROPIC_BASE_URL="http://10.0.0.203:1234" 
        # export ANTHROPIC_BASE_URL="http://127.0.0.1:1234" 
      '';
    };

    tmux = {
      enable = true;
      escapeTime = 0;
      plugins = [
        pkgs.tmuxPlugins.vim-tmux-navigator
        pkgs.tmuxPlugins.catppuccin
      ];
      extraConfig = builtins.readFile ./config/tmux.conf;
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    neovide.enable = true;

    git = {
      enable = true;
      package = pkgs.gitFull;

      settings = {
        user.name = "Colin Olson";
        user.email = "thecolin@gmail.com";
        alias = {
          ci = "commit";
          co = "checkout";
          st = "status";

          g = "!git gui &";
          v = "!gitk --all &";
        };
      };

    };

    yazi = {
      enable = true;
      enableZshIntegration = true;

      keymap = {
        mgr.prepend_keymap = [
          {
            on = [
              "g"
              "w"
            ];
            run = "cd ~/Work";
            desc = "Go Work";
          }

          {
            on = [
              "g"
              "d"
            ];
            run = "cd ~/Dotfiles";
            desc = "Go Dotfiles";
          }
        ];
      };

    };

    home-manager.enable = true;
  };

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 600;
        command = "/home/colino/.nix-profile/bin/noctalia-shell ipc call lockScreen lock";
      }
      {
        timeout = 630;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
      }
    ];
    events.after-resume = "${pkgs.niri}/bin/niri msg action power-on-monitors";
  };

  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
  };
}
