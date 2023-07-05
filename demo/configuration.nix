{ config, pkgs, ... }: {
  system.stateVersion = "23.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = [ pkgs.hamster ];

  networking.hostName = "nixos";

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  users.users.alice = {
    isNormalUser = true;
    password = "bob"; # TODO: Insecure
    extraGroups = [ "wheel" ];
  };
}
