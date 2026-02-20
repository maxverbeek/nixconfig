{ pkgs }:

pkgs.mkShell {
  name = "nixos-installer";
  
  buildInputs = with pkgs; [
    # Core NixOS installation tools
    nixos-install-tools
    
    # Partitioning and filesystem tools
    parted
    gptfdisk
    e2fsprogs
    dosfstools
    btrfs-progs
    zfs
    
    # Useful utilities
    git
    curl
    wget
    
    # Text editors
    vim
    nano
    
    # System information
    pciutils
    usbutils
    lshw
  ];
  
  shellHook = ''
    echo "NixOS Installation DevShell"
    echo "=========================="
    echo ""
    echo "Available tools:"
    echo "  - nixos-generate-config: Generate NixOS configuration"
    echo "  - nixos-install: Install NixOS"
    echo "  - parted/gdisk: Disk partitioning"
    echo "  - mkfs.*: Filesystem creation"
    echo ""
    echo "Useful commands:"
    echo "  - lsblk: List block devices"
    echo "  - fdisk -l: List disk partitions"
    echo "  - nixos-generate-config --root /mnt"
    echo "  - nixos-install --flake .#<hostname>"
    echo ""
  '';
}
