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
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          codex = pkgs.callPackage ./pkgs/codex/package.nix { };
        in
        {
          inherit codex;
          default = codex;
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
