{pkgs, ...}:
let
  ssid = "foobarbaz";
  password = "slashroot";
  interface = "wlo1";
in
{
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
  };
  hardware.enableRedistributableFirmware = true;

  networking.useDHCP = true;
  services.resolved.enable = false; # Probably useful to enable for systemd-networkd
  networking = {
    wireless = {
      enable = true;
      networks.${ssid}.psk = password;
      interfaces = [ interface ];
    };
  };

}
