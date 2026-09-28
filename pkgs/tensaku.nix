# Tensaku isn't in nixpkgs and its upstream flake only provides a dev shell,
# so it's packaged here. Based on the nixpkgs satty derivation, which Tensaku
# is a fork of.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook4,
  installShellFiles,
  gdk-pixbuf,
  glib,
  gtk4,
  gtk4-layer-shell,
  libadwaita,
  libepoxy,
  libGL,
  libxkbcommon,
  fontconfig,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tensaku";
  version = "0.29.0";

  src = fetchFromGitHub {
    owner = "jondkinney";
    repo = "tensaku";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IAjvMaN0R+dPtdOR26uLYRT+yjpIz/ZA3V4pKa6nue4=";
  };

  cargoHash = lib.fakeHash;

  # Writes shell completions and the man page into the source tree.
  buildFeatures = [ "ci-release" ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    installShellFiles
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gtk4
    gtk4-layer-shell
    libadwaita
    libepoxy
    libGL
    libxkbcommon
    fontconfig
  ];

  postInstall = ''
    install -Dm755 assets/tensaku-edit -t $out/bin
    install -Dm644 dev.tensaku.Tensaku.desktop -t $out/share/applications
    install -Dm644 assets/tensaku.svg $out/share/icons/hicolor/scalable/apps/dev.tensaku.Tensaku.svg
    installManPage man/tensaku.1
    installShellCompletion --cmd tensaku \
      --bash completions/tensaku.bash \
      --fish completions/tensaku.fish \
      --zsh completions/_tensaku
  '';

  meta = {
    description = "Screenshot annotation tool for Wayland, a fork of Satty";
    homepage = "https://github.com/jondkinney/tensaku";
    license = lib.licenses.mpl20;
    mainProgram = "tensaku";
    platforms = lib.platforms.linux;
  };
})
