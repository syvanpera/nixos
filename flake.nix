{
  description = "Tuomo's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    apple-fonts.inputs.nixpkgs.follows = "nixpkgs";

    aven.url = "github:raine/aven";
    aven.inputs.nixpkgs.follows = "nixpkgs";

    awww.url = "git+https://codeberg.org/LGFae/awww";
    awww.inputs.nixpkgs.follows = "nixpkgs";

    workmux.url = "github:raine/workmux";
    workmux.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, apple-fonts, aven, awww, workmux, ... }@inputs: {
    # Build/switch with: sudo nixos-rebuild switch --flake .#<host>
    nixosConfigurations = {
      tuxedo = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = [ ./hosts/tuxedo ];
      };
    };
  };
}
