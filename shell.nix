{pkgs, ...}:
let
  elp = pkgs.callPackage ./nix/elp.nix {};
in
pkgs.mkShell {
  buildInputs =
    (with pkgs; [
      nixfmt-rfc-style
      elp
    ])
    ++ (with pkgs.beam.packages.erlang_27; [
      erlang
      rebar3
      erlang-ls
    ]);
}
