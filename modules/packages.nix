# Packages installed into the system profile.
# Search for more at https://search.nixos.org/
{ pkgs, inputs, ... }:

let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # nixpkgs builds voxtype CPU-only, and whisper on the CPU takes most of a
  # clip's own length to transcribe it. With Vulkan it runs on the iGPU. An
  # overlay rather than a local override so the user service in services.nix
  # gets the same build.
  nixpkgs.overlays = [
    (final: prev: {
      voxtype = prev.voxtype.override { vulkanSupport = true; };
    })
  ];

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
    tree-sitter
    tmux
    starship
    bat
    ripgrep
    jq
    zed-editor
    zoxide
    atuin
    bluetui
    unzip
    nodejs
    uv
    lua-language-server
    stylua
    mcp-nixos
    hyprmoncfg
    hyprsunset
    delta
    hunk
    lazygit
    slurp
    grim
    xdg-user-dirs
    github-cli
    fd
    sesh
    television
    wtype
    morewaita-icon-theme
    imagemagick
    wl-clipboard
    cliphist
    nautilus
    obsidian
    awww
    slack
    go
    gopls
    typescript-language-server
    vscode-json-languageserver
    yaml-language-server
    tailwindcss-language-server
    biome
    libnotify
    voxtype

    inputs.aven.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.superfile.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.yazi.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    llm-agents.claude-code
    llm-agents.opencode
    llm-agents.pi
  ];
}

