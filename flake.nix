{
  description = "Tuomo's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # San Francisco Fonts | Apple Fonts
    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    apple-fonts.inputs.nixpkgs.follows = "nixpkgs";

    # Aven, a local-first TUI task manager
    aven.url = "github:raine/aven";
    aven.inputs.nixpkgs.follows = "nixpkgs";

    # Workmux, a workflow tool for managing git worktrees and tmux
    workmux.url = "github:raine/workmux";
    workmux.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, apple-fonts, aven, workmux, ... }@inputs: {
    # Build/switch with: sudo nixos-rebuild switch --flake .#<host>
    nixosConfigurations = {
      tuxedo = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = [ ./hosts/tuxedo ];
      };
    };
  };
}
