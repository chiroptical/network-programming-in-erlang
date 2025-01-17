{pkgs, ...}:
pkgs.mkShell {
  buildInputs =
    (with pkgs; [
      # nix tools
      alejandra
    ])
    ++ (with pkgs.beam.packages.erlang_27; [
      erlang
      rebar3
      erlang-ls
    ]);
}
