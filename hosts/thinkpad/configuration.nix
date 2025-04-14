# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ../../modules/kvm2.nix
    ../../modules/bluetooth.nix
    ../../modules/wayland
    ../../modules/pipewire.nix
    ../../modules/nix.nix
    ../../modules/shell.nix
    ../../modules/1password.nix
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-uuid/6e465077-1649-4e33-a5bf-55274047905c";
    preLVM = true;
    allowDiscards = true;
  };

  boot.kernelParams = [ "i915.force_probe=7d55" ];
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "thinkpad"; # Define your hostname.
  networking.networkmanager.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    vaapiIntel
    intel-media-driver
  ];

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Attempt to save some battery
  services.tlp = {
    # test if this kills wifi
    enable = false;

    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
  };

  hardware.pulseaudio.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
    touchpad.disableWhileTyping = true;
  };

  # battery monitoring
  services.upower.enable = true;
  services.gvfs.enable = true;

  # monitoring brightness
  programs.light.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.max = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "plugdev"
      "dialout"
      "input"
      "video"
      "adbusers"
    ];
    packages = with pkgs; [
      tree
    ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    corefonts
    custom.fa-custom
    custom.teg-font
    hack-font
    noto-fonts
    powerline-fonts
    roboto
    roboto-mono
    source-code-pro
    terminus_font
    ubuntu_font_family

    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # programs.firefox.enable = true;

  virtualisation.docker = {
    enable = true;
    package = pkgs.unstable.docker.override { buildxSupport = true; };
  };

  # allow docker to access the host network from containers via the bridge
  # interfaces. they always seem to use 172.16.0.0/12 IPs
  networking.firewall.extraCommands = ''
    iptables -I INPUT 1 -s 172.16.0.0/12 -p tcp -d 172.17.0.1 -j ACCEPT
    iptables -I INPUT 2 -s 172.16.0.0/12 -p udp -d 172.17.0.1 -j ACCEPT
  '';

  modules.kvm2.enable = true;
  modules.kvm2.home.minikube.enable = true;

  networking.firewall.allowedTCPPorts = [
    3000
    3100
    3200
  ];

  networking.extraHosts = ''
    49.12.21.124 retriever.dev.legalmike.ai
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}
