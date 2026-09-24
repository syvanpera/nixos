{
  description = "Tuomo's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    apple-fonts.inputs.nixpkgs.follows = "nixpkgs";

    # The desktop shell. A local branch while its flake is being built;
    # github:syvanpera/kuori once that is merged.
    kuori.url = "git+file:///home/tuomo/work/personal/kuori?ref=nix-flake";
    kuori.inputs.nixpkgs.follows = "nixpkgs";

    aven.url = "github:raine/aven";
    aven.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";

    superfile.url = "github:yorukot/superfile";
    superfile.inputs.nixpkgs.follows = "nixpkgs";

    workmux.url = "github:raine/workmux";
    workmux.inputs.nixpkgs.follows = "nixpkgs";

    yazi.url = "github:sxyazi/yazi";
    yazi.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, apple-fonts, aven, llm-agents, workmux, zen-browser, ... }@inputs: {
    # Build/switch with: sudo nixos-rebuild switch --flake .#<host>
    nixosConfigurations = {
      tuxedo = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = [
          inputs.kuori.nixosModules.default
          ./hosts/tuxedo
        ];
      };

      milliways = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = [
          inputs.kuori.nixosModules.default
          ./hosts/milliways
        ];
      };
    };
  };
}
