{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "lazyjira";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "textfuel";
    repo = "lazyjira";
    rev = "v${version}";
    hash = "sha256-K1jT+6ayJG+S6rSZZDeOHU9omM/1lIcyDBd4po2g9Us=";
  };

  subPackages = [ "cmd/lazyjira" ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${version}"
  ];

  vendorHash = "sha256-+Vepf1VohkjtL7JvmuZv8qZ5FiLarII+bx4jK6C2bBU=";

  meta = with lib; {
    description = "Terminal UI for Jira";
    homepage = "https://github.com/textfuel/lazyjira";
    license = licenses.mit;
    mainProgram = "lazyjira";
    platforms = platforms.unix;
  };
}
