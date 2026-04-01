# Repository Guidelines

## Project Structure & Module Organization
This repository is a Nix flake for system and home-manager configuration. Core entrypoints live in `flake.nix`, `configuration.nix`, and `home.nix`. Reusable NixOS modules are in `modules/` (`programs.nix`, `services.nix`, `systemPackages.nix`). Host-specific hardware files live under `machines/<hostname>/`. Custom packages belong in `pkgs/<name>/default.nix`. User-facing config files are kept in `config/`, and helper scripts are in `bin/`.

## Build, Test, and Development Commands
Use commands from the repo root:

- `nix flake check` validates flake evaluation.
- `nix build .#nixosConfigurations.nixos-desktop.config.system.build.toplevel` builds the desktop system without switching.
- `home-manager switch --flake .#colino` applies home-manager changes.
- `~/bin/nrs` rebuilds and switches the current host using `$HOSTNAME`.
- `nix build --no-link --impure --expr 'let flake = builtins.getFlake (toString ./.); pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; overlays = [ flake.overlays.default ]; }; in pkgs.callPackage ./pkgs/<name> { }'` validates a custom package derivation.

## Coding Style & Naming Conventions
Nix files use two-space indentation and concise attribute sets, consistent with `configuration.nix`. Prefer small, focused modules over large mixed-purpose files. Name custom packages by directory, for example `pkgs/lazyjira/default.nix`. Keep host-specific data in `machines/<hostname>/` and avoid hardcoding host names elsewhere unless required.

Format and lint before submitting:

- `nixfmt <file>.nix` for Nix files
- `statix check .` for Nix linting
- `stylua config/nvim` for Neovim Lua

## Testing Guidelines
There is no formal unit test suite here. Treat evaluation and build success as the baseline:

- Run `nix flake check` after structural changes.
- Build the affected host or package before switching.
- For Home Manager or Neovim edits, run the relevant switch/build command and confirm the generated config loads cleanly.

## Commit & Pull Request Guidelines
Recent commits use short, imperative subjects such as `Change system python. Add killf` and `Flake update`. Keep commit titles brief, specific, and action-oriented. Pull requests should include:

- a short summary of the changed module or host
- the command(s) used to validate the change
- screenshots only for visible UI/config changes such as Niri, Plasma, or Neovim

## Security & Configuration Tips
Be careful with secrets and machine-local values. This repo contains real usernames, hostnames, firewall settings, and shell aliases; do not add tokens or private keys. Review `services.nix` and `configuration.nix` closely when changing networking, sudo, or udev rules.
