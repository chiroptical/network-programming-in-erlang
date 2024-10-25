{
  description = "Network programming in Erlang";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachSystem ["x86_64-linux" "x86_64-darwin" "aarch64-darwin"] (system: let
      erlang_27_rebar_overlay = final: prev: {
        rebar3 = prev.rebar3.overrideAttrs (oldAttrs: {
          buildInputs = [ final.erlang_27 ];
        });
      };

      pkgs = import nixpkgs {
        inherit system;
        config.allowBroken = true;
        overlays = [ erlang_27_rebar_overlay ];
      };
    in {
      devShell = import ./shell.nix {
        inherit pkgs;
      };
      # defaultPackage = ...;
      packages = flake-utils.lib.flattenTree {
        # inherit ...;
      };
    });
}
