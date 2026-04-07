{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "purple";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "erickochen";
    repo = "purple";
    rev = "v${version}";
    hash = "sha256-Td/Pxa6cJxzR5UffpL8ps4RVgHu9c5n0WS0f3HYuvno=";
  };

  cargoHash = "sha256-rCU7uNKIsFNvlLX9XsOiBlMu+wHezMq38YKnE/r5G4o=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "Smart, fast SSH launcher for the terminal";
    homepage = "https://github.com/erickochen/purple";
    license = licenses.mit;
    mainProgram = "purple";
    platforms = platforms.unix;
  };
}
