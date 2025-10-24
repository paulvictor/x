{lib, pkgs, ...}:
{
  security.sudo.wheelNeedsPassword = false;
  users.users = {
    root = {
      hashedPassword = ""; # "" means passwordless login
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFoERTN+ojo/bTUv7/jyKYd12OoS9WJktLB8pEIQP/3s" ];
    };
    viktor = {
      isNormalUser = true;
      createHome = true;
      home = "/home/viktor";
      hashedPassword = ""; # "" means passwordless login
      shell = lib.getExe pkgs.zsh;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFoERTN+ojo/bTUv7/jyKYd12OoS9WJktLB8pEIQP/3s" ];

    };
  };
}
