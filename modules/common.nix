# Common to host and vm
{pkgs, lib, ...}:
{
  imports =
    [
      ./users.nix
    ];
#   system.stateVersion = config.system.nixos.version;

  system.stateVersion = "25.11";
  boot.supportedFilesystems.zfs = lib.mkForce false;
  programs.htop.enable = true;
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
  };

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  environment.systemPackages = with pkgs;[ jq ];
  networking.firewall.enable = false;

  # https://github.com/NixOS/nixpkgs/issues/119710#issuecomment-1899293945
  security.pam.services.sshd.allowNullPassword = true;
  services.openssh = {
    enable = true;
    settings = {
      UsePAM = false;
      PermitRootLogin = "yes";
      PermitEmptyPasswords = "yes";
    };
  };
  services.getty.autologinUser = "root";

}
