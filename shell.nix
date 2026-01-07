{pkgs, ...}:
pkgs.mkShell {
  buildInputs =
    (with pkgs; [
      nixfmt-rfc-style
      erlang-language-platform
    ])
    ++ (with pkgs.beam.packages.erlang_27; [
      erlang
      rebar3
    ]);
}
