{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  libfido2,
  libsecret,
}:

buildGoModule rec {
  pname = "protonmail-bridge";
  version = "3.23.1";

  src = fetchFromGitHub {
    owner = "mnixry";
    repo = "proton-bridge";
    rev = "495d5f0d9e88a6e75bfd496fc6234a51b61de7f1";
    hash = "sha256-xIeh3cp8kxZJ1mkARhrD9a1UVLKrixfGyJnIPAI+B6w=";
  };

  vendorHash = "sha256-Ww42BbdMHVUUc074vWNYTEMr1myqDPLgkMsaTarziag=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libsecret libfido2 ];

  preBuild = ''
    patchShebangs ./utils/
    (cd ./utils/ && ./credits.sh bridge)
  '';

  ldflags =
    let
      constants = "github.com/mnixry/proton-bridge/v3/internal/constants";
    in
    [
      "-X ${constants}.Version=${version}"
      "-X ${constants}.Revision=${src.rev}"
      "-X ${constants}.buildTime=unknown"
      "-X ${constants}.FullAppName=ProtonMailBridge" # Should be "Proton Mail Bridge", but quoting doesn't seems to work in nix's ldflags
    ];

  subPackages = [
    "cmd/Desktop-Bridge"
  ];

  postInstall = ''
    mv $out/bin/Desktop-Bridge $out/bin/protonmail-bridge # The cli is named like that in other distro packages
  '';
  meta.mainProgram = "${pname}";
}

