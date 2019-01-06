# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "ohci_pci" "ehci_pci" "ahci" "firewire_ohci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" "wl" "forcedeth" "b43" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.kernelParams = [ "irqpoll" ];  # noapic seems to improve things

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4568bf11-6e40-4514-9bc9-3194a299c45f";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/67E3-17ED";
      fsType = "vfat";
    };

  zramSwap = { enable = true; priority = 1000; };
  swapDevices = [
    { device = "/dev/disk/by-uuid/f602ea23-99e5-416b-98d2-ef76cbc5c934";
    } ];

  nix.maxJobs = lib.mkDefault 2;

  services.xserver.videoDriver = "nouveau";
}
