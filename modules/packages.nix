# Packages installed into the system profile.
# Search for more at https://search.nixos.org/
{ pkgs, inputs, ... }:

let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
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
    (python3.withPackages (ps: [ ps.jeepney ]))
    uv
    lua-language-server
    stylua
    mcp-nixos
    hyprmoncfg
    hyprsunset
    hyprpicker
    libnotify
    delta
    hunk
    lazygit
    slurp
    grim
    wf-recorder
    xdg-user-dirs
    grimblast
    github-cli
    fd
    sesh
    television
    wtype
    morewaita-icon-theme
    imagemagick
    wl-clipboard
    cliphist
    qt6.qtimageformats
    nautilus
    obsidian
    awww
    slack

    inputs.aven.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    llm-agents.claude-code
    llm-agents.opencode
    llm-agents.pi
  ];
}

