{pkgs, ...}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    # nix tools
    alejandra

    # erlang stuff
    erlang_27
    rebar3
  ];
}
