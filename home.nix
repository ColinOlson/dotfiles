# vim: set ts=2 sw=2:

{
  config,
  pkgs,
  noctalia,
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

    packages = with pkgs; [
      statix # Nix static analyzer? Shuts vim up
      zsh-powerlevel10k
      quickshell
    ];

    file = {
      ".p10k.zsh".source = ./config/p10k.zsh;
      "bin".source = ./bin;
    };

    sessionVariables = {
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    noctalia-shell = {
      enable = true;
    };

    keepassxc.enable = true;

    bash.enable = true;

    zsh = {
      enable = true;

      # Optional but recommended quality-of-life
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        "ls" = "eza --icons -l";
        "ll" = "ls";
        "l" = "ll";
        "la" = "l -a";

        "vrc" = "zsh -c 'cd ~/Dotfiles; vi configuration.nix'";
        "src" = "zsh -c 'cd ~/Dotfiles; sudo nixos-rebuild switch --flake .;' source ~/.zshrc";
        "vrh" = "zsh -c 'cd ~/Dotfiles; vi home.nix'";
        "srh" = "zsh -c 'cd ~/Dotfiles; home-manager switch --flake .;' source ~/.zshrc";
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
        # Powerlevel10k (theme)
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

        # If you have a p10k config file, load it
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
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

          g = "!git gui";
          v = "!gitk --all";
        };
      };
    };

    home-manager.enable = true;
  };

  xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Dotfiles/config/nvim";
}
