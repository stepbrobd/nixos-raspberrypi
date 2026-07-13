# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/development/libraries/libraspberrypi/default.nix#L28
# because libraspberrypi is outdated and deprecated
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  dtc,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "raspberrypi-utils";
  version = "0-unstable-2026-07-08";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "utils";
    rev = "5edd399260b5081f9c1c96fc7f369b920d6732d1";
    hash = "sha256-qxwASdmEH47oCjuPtboWuUkcNsw5j6eCSsWrNejpIMU=";
  };

  buildInputs = [
    dtc # dtmerge depends on libfdt
    ncurses
  ];

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A collection of scripts and simple applications for Raspberry Pi hardware";
    homepage = "https://github.com/raspberrypi/utils";
    license = licenses.bsd3;
    platforms = [
      "armv6l-linux"
      "armv7l-linux"
      "aarch64-linux"
    ];
    maintainers = with maintainers; [ kazenyuk ];
  };
})
