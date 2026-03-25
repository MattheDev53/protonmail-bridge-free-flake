{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
  };
  outputs =
    {
      self,
      nixpkgs,
      systems,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      packages = eachSystem (
        system:
        let
          pkgs = import nixpkgs { system = "${system}"; };
        in
        {
          default = self.packages.${system}.proton-mail-free-flake.cli;
          proton-mail-free-flake = {
            cli = pkgs.callPackage ./default.nix { };
          };
        }
      );
      devShells = eachSystem (
        system:
        let
          pkgs = import nixpkgs { system = "${system}"; };
        in
        {
          default = pkgs.mkShellNoCC { packages = with pkgs; [ ]; };
        }
      );
    };
}
