{
  description = "Tuomo's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    apple-fonts.inputs.nixpkgs.follows = "nixpkgs";

    aven.url = "github:raine/aven";
    aven.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";

    workmux.url = "github:raine/workmux";
    workmux.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, apple-fonts, aven, llm-agents, workmux, ... }@inputs: {
    # Build/switch with: sudo nixos-rebuild switch --flake .#<host>
    nixosConfigurations = {
      tuxedo = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = [ ./hosts/tuxedo ];
      };
    };
  };
}
