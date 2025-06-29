# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

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

    # set up networkign in this file
    ./networking.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [ ];
  boot.initrd.availableKernelModules = [ "btusb" ];

  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-uuid/6e6ef9ba-0ecf-4c94-9a31-1c417274cec3";
    preLVM = true;
    allowDiscards = true;
  };

  boot.initrd.systemd.enable = true;
  boot.plymouth = {
    enable = true;
    logo = ../../wallpapers/thonkpad.png;
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics.enable = true;

  networking.hostName = "lenovo-laptop"; # Define your hostname.

  # networking.nameservers =
  #   [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];

  networking.extraHosts = ''
    127.0.0.1 keycloak
    127.0.0.1 s3
    49.12.21.124 retriever.dev.legalmike.ai
  '';

  networking.networkmanager = {
    enable = true;
    # ignore docker interfaces
    # unmanaged = [ "interface-name:veth*" "interface-name:docker0" ];
  };

  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };

  # networking.wireless.enable = false;
  # networking.wireless.interfaces = [ "wlp4s0" ];

  programs.nm-applet.enable = true;
  programs.light.enable = true;
  programs.adb.enable = true;

  programs.steam.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.

  # see ./networking.nix

  # networking.useDHCP = false;
  # networking.useNetworkd = true;
  # networking.interfaces.enp2s0.useDHCP = true;
  # networking.interfaces.wlp4s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Configure keymap in X11
  services.xserver = {
    enable = true;

    xkb = {
      layout = "us";
      options = "eurosign:e";
    };

    # videoDrivers = [ "radeon" ];
    autoRepeatDelay = 250;
    autoRepeatInterval = 50;
    # desktopManager.xterm.enable = true;
    desktopManager.session = [
      {
        manage = "desktop";
        name = "home-manager";
        start = "exec $HOME/.xsession &";
      }
    ];

    displayManager.lightdm.greeters.mini = {
      enable = true;
      user = "max";
    };
  };

  services.displayManager = {
    defaultSession = "home-manager";
    logToJournal = true;
  };

  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
    touchpad.disableWhileTyping = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Attempt to save some battery
  services.tlp = {
    # test if this kills wifi
    enable = false;

    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  # battery monitoring
  services.upower.enable = true;
  services.gvfs.enable = true;

  # test if this kills wifi
  powerManagement.powertop.enable = false;

  # Enable sound.
  services.pulseaudio.enable = true;

  ## Instead of using pulseaudio, try pipewire
  # rtkit is optional but recommended
  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = false;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  # };

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
    ]; # Enable ‘sudo’ for the user.
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

    nerd-fonts.jetbrains-mono
  ];

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    git
    killall
    vim

    nodejs
    yarn

    citrix_workspace
  ];

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
  networking.firewall.allowedTCPPorts = [
    3000
    3100
    3200
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
