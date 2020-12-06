{ config, pkgs, ... }:
let pico8 = (import ./pico8.nix);
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.timeout = 0;
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };


  time.timeZone = "America/Los_Angeles";

  networking = {
    hostName = "pico8";
    useDHCP = false;
    interfaces.wlp1s0.useDHCP = true;
    wireless = {
      enable = true;
      networks = (import ./secrets.nix).networks;
    };


    firewall.allowedTCPPorts = [ 22 ];
    firewall.allowedUDPPorts = [ 22 ];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  sound.enable = true;

  hardware = {
    pulseaudio.enable = true;
    opengl.enable = true;
  };


  environment.systemPackages = with pkgs; [
    cage
    pico8
    pavucontrol
    wget
    wpa_supplicant

  ];


  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
    passwordAuthentication = true;
 };

  services.cage = {
    enable = false; # if true, system will boot into pico8
    user = "pico8";
    program = "${pico8}/bin/pico8";
  };


  users.users = {

    pico8 = {
      isNormalUser = true;
    };
  };


  system.stateVersion = "20.09";

}
