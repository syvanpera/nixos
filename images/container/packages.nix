# Packages in the Incus container image. Independent of the hosts'
# modules/packages.nix: nothing from there ends up in the image.
{ pkgs, inputs, ... }:

let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  environment.systemPackages = with pkgs; [
    curl
    fd
    git
    htop
    jq
    ripgrep
    neovim
    python3

    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default

    llm-agents.claude-code
  ];
}
