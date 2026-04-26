{ ... }:
# Single /dev/sda — GPT with BIOS boot partition, LVM for swap + root.
# VM uses SeaBIOS (BIOS, not UEFI).
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          bios_boot = {
            size = "1M";
            type = "EF02";   # GRUB BIOS boot — not mounted, just required
            priority = 1;
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
    "ahci" "virtio_pci" "virtio_scsi" "virtio_blk" "sd_mod"
  ];
  # dm_mod must load early so device mapper is ready before lvm2 scans the VG.
  boot.initrd.kernelModules = [ "dm_mod" ];

  hardware.enableRedistributableFirmware = true;
}
