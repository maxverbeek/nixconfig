# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/kvm2.nix
    # ./vim.nix
    # ./i3.nix
  ];

  # Use experimental nix flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "@wheel" ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  networking.hostName = "desknix"; # Define your hostname.
  networking.hostId = "aa111111"; # required for zfs
  networking.nameservers =
    [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];

  networking.extraHosts = ''
    127.0.0.1 keycloak
  '';

  # Set your time zone.
  # Also set hardware clock to local, since that's what windows uses
  time = {
    timeZone = "Europe/Amsterdam";
    hardwareClockInLocalTime = true;
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  hardware.cpu.intel.updateMicrocode = true;

  services.teamviewer.enable = false;

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";
    videoDrivers = [ "nvidia" ];
    autoRepeatDelay = 250;
    autoRepeatInterval = 50;
    desktopManager.xterm.enable = true;
    displayManager.lightdm.greeters.mini = {
      enable = true;
      user = "max";
    };
    desktopManager.session = [{
      manage = "desktop";
      name = "default"; # was previously "home-manager"
      start = ''
        exec $HOME/.xsession &
      '';
    }];
    # apparently not used, this is the default value.
    displayManager.defaultSession = "default";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.gnome.gnome-keyring.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.daemon.config.default-sample-format = "s24le";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.max = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # Fix required to set zsh as shell
  # Fix: apparently not, thought this solved issues with
  # steam-run, but it works fine now...
  # programs.zsh.enable = true;

  # Fonts
  fonts.fonts = with pkgs; [
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

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    git
    killall
    vim

    nodejs
    yarn
  ];

  virtualisation.docker = {
    enable = true;
    # storageDriver = "zfs"; # according to internet, overlayfs + zfs = bad
  };

  modules.kvm2.enable = true;
  modules.kvm2.home.minikube.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
