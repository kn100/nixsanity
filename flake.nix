{
  description = "NixOS configurations for faith and glados";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      nixosConfigurations = {
        joker = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/joker
          ];
        };
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              nixos-rebuild
              yj
              age
              sops
              nixpkgs-fmt
              nh
              jq
            ];

            shellHook = ''
              echo "--- Nixsanity Development Shell ---"
            '';
          };
        }
      );
    };
}
