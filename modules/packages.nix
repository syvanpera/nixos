# Packages installed into the system profile.
# Search for more at https://search.nixos.org/
{ pkgs, inputs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    gcc
    git
    go
    neovim
    wget
    procs
    eza
    fsel
    ghostty
    chromium
    hyprpolkitagent
    quickshell
    tree-sitter
    tmux
    starship
    bat
    ripgrep
    jq
    brightnessctl
    zed-editor
    kdePackages.qtdeclarative
    kdePackages.qtmultimedia
    zoxide
    atuin
    bluetui
    unzip
    nodejs
    python3
    uv
    lua-language-server
    stylua
    claude-code
    mcp-nixos
    hyprmoncfg
    delta
    hunk
    lazygit
    slurp
    grim
    github-cli
    fd
    sesh
    television
    imagemagick

    inputs.aven.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
    inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
