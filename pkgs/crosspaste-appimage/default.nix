{
  lib,
  fetchurl,
  appimageTools,
}:

let
  version = "1.2.7.1883"; # example – match the release you want
  src = fetchurl {
    # Grab the exact asset URL from the GitHub release page / crosspaste download page
    url = "https://github.com/CrossPaste/crosspaste-desktop/releases/download/1.2.7.1883/crosspaste-1.2.7-1883-amd64.AppImage";
    sha256 = "sha256-ZpNvS1nLE56PaSM1luZqy8LwWVOz8hSgZwNhZ5Zgvwo=";
  };
in
appimageTools.wrapType2 {
  pname = "crosspaste";
  inherit version src;

  # Optional: nice desktop integration/name
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    # If the AppImage contains a desktop file/icon, wrapType2 often exposes it; otherwise we can add our own .desktop later.
  '';

  meta = with lib; {
    description = "Cross-device clipboard sync tool (AppImage wrapped)";
    homepage = "https://github.com/CrossPaste/crosspaste-desktop";
    license = licenses.asl20; # verify upstream’s license if you care; adjust if different
    platforms = platforms.linux;
  };
}
