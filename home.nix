{ config, pkgs, ... }:

{
  home.username = "colino";
  home.homeDirectory = "/home/colino";

  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    zsh-powerlevel10k
  ];

  home.file = {
    ".p10k.zsh".source = ./.p10k.zsh;
  };

  programs.bash.enable = true;
  programs.zsh = { 
    enable = true;

    # Optional but recommended quality-of-life
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" "python" "pip" "sudo" ];
      # We'll set the theme via initExtra so it’s explicit and flexible.
      theme = ""; 
    };

    initContent = ''
      # Powerlevel10k (theme)
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # If you have a p10k config file, load it
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    '';
  };

  programs.neovide.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.sessionVariables = {
    COLIN = "Hello again";

    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib
      pkgs.openssl
      pkgs.libffi
    ];

    NIX_CFLAGS_COMPILE = "-I${pkgs.openssl.dev}/include";
    NIX_LDFLAGS = "-L${pkgs.openssl.out}/lib";
  };

  programs.home-manager.enable = true;
}
