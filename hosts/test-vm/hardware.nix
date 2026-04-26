{ ... }:
# Single /dev/sda — GPT, EFI boot, LVM for swap + root.
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "defaults" "umask=0077" ];
            };
          };
          root_pv = {
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "nixos";
            };
          };
        };
      };
    };

    lvm_vg.nixos = {
      type = "lvm_vg";
      lvs = {
        swap = {
          size = "4G";
          content.type = "swap";
        };
        root = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = [ "defaults" "noatime" ];
          };
        };
      };
    };
  };

  boot.initrd.availableKernelModules = [
    "ahci" "virtio_pci" "virtio_blk" "sd_mod" "xhci_pci"
    "dm_mod" "dm_thin_pool"
  ];

  hardware.enableRedistributableFirmware = true;
}
