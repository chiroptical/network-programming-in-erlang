{
  pkgs,
  system,
  ...
}:
let
  version = "2025-02-13";
  erlangVersion = "27.1";
in
pkgs.stdenv.mkDerivation {
  name = "elp";

  src =
    if builtins.elem system [ "aarch64-darwin" ] then
      pkgs.fetchzip {
        url = "https://github.com/WhatsApp/erlang-language-platform/releases/download/${version}/elp-macos-aarch64-apple-darwin-otp-${erlangVersion}.tar.gz";
        sha256 = "sha256-AMKVn1x325R+1E9BMpo37Xezsp+EP5AmkMEEX6hYcQA=";
      }
    # x86_64-linux
    else
      pkgs.fetchzip {
        url = "https://github.com/WhatsApp/erlang-language-platform/releases/download/${version}/elp-linux-x86_64-unknown-linux-gnu-otp-${erlangVersion}.tar.gz";
        sha256 = "sha256-UVhUUKOcZmfB8mvjpKJJBUlSEgTBQyJOV7CH9srwpD4=";
      };

  installPhase = ''
    mkdir -p $out/bin
    cp $src/elp $out/bin
  '';
}
