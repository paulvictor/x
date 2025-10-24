{pkgs, lib, specialArgs, inputs, ...}:

{
  imports = [
    inputs.microvm.nixosModules.host
    ./networking.nix
  ];
  environment.systemPackages = with pkgs;[
    libvirt
  ];
  microvm.host.useNotifySockets = true;
}
