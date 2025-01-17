{
  description = "Network Programming in Elixir and Erlang";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  };

  outputs = {nixpkgs, ...}: let
    supportedSystems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    forAllSystems = function:
      nixpkgs.lib.genAttrs supportedSystems (
        system: function nixpkgs.legacyPackages.${system}
      );
  in {
    devShells = forAllSystems (pkgs: {
      default = pkgs.callPackage ./shell.nix {};
    });
  };
}
