{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./system/boot/loader/raspberrypi
    ./configtxt.nix
    ./udev.nix
    # config.txt is in `config.hardware.raspberry-pi.config-generated`
    ./configtxt-config.nix
  ];

  boot.loader.raspberry-pi = {
    enable = true;
  };

  hardware.raspberry-pi.config.all.options = {
    arm_64bit = {
      enable = true;
      value = true;
    };
    enable_uart = {
      enable = true;
      value = true;
    };
    avoid_warnings = {
      enable = lib.mkDefault true;
      value = lib.mkDefault true;
    };
  };

  # Workaround for `Couldn't write '33' to 'vm/mmap_rnd_bits': Invalid argument`,
  # both RPi4 and RPi5 seem to be affected, see:
  # 1. https://github.com/NixOS/nixpkgs/issues/513512
  # 2. https://github.com/NixOS/nixpkgs/commit/4971c9331a72deeda85ba8d8018a5b07ee6f1635
  # RPi5 16k kernel should set ARM64_16K_PAGES in nixos config explicitly
  # for the check from (2) to work, but the `31` still won't work, so set the
  # value back to the default before the change in (2)
  boot.kernel.sysctl."vm.mmap_rnd_bits" = 18;

  boot.consoleLogLevel = lib.mkDefault 7;
  # https://github.com/raspberrypi/firmware/issues/1539#issuecomment-784498108
  # https://github.com/RPi-Distro/pi-gen/blob/master/stage1/00-boot-files/files/cmdline.txt
  boot.kernelParams = [
    "console=serial0,115200n8"
    "console=tty1"
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    # https://github.com/NixOS/nixos-hardware/issues/631#issuecomment-1584100732
    "usbhid"
    "usb_storage"
    "vc4"
    "pcie_brcmstb" # required for the pcie bus to work
    "reset-raspberrypi" # required for vl805 firmware to load
  ];
  hardware.enableRedistributableFirmware = true;

  environment.systemPackages = with pkgs; [
    raspberrypi-utils
  ];

  # workaround for "modprobe: FATAL: Module <module name> not found"
  # see https://github.com/NixOS/nixpkgs/issues/154163,
  #     https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
}
