{
  description = "Custom Nix application packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      codexOverlay = final: _prev: {
        codex = final.callPackage ./pkgs/codex/package.nix { };
      };
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ codexOverlay ];
      };
    in
    {
      overlays.default = codexOverlay;

      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          inherit (pkgs) codex;
          default = pkgs.codex;
        });

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShellNoCC {
            packages = [ pkgs.nix-update ];
          };
        });
    };
}
