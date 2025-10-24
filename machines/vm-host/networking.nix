{pkgs, ...}:
{
  environment.systemPackages = with pkgs;[
    # only for wireless
    iw wpa_supplicant ebtables hostapd wirelesstools
  ];
  networking.useNetworkd = false;
  systemd.network.enable = true;

  systemd.network.netdevs."10-microvm".netdevConfig = {
    Kind = "bridge";
    Name = "br0";
  };
  systemd.network.networks."10-microvm" = {
    matchConfig.Name = "br0";
    networkConfig = {
      DHCPServer = true;
    };
    addresses = [ {Address = "192.168.0.1/16";} ];
    dhcpServerConfig = {
      PersistLeases = false;
      PoolOffset = 10;
      EmitDNS = true;
    };
  };

  # Allow inbound traffic for the DHCP server
  networking.firewall.allowedUDPPorts = [ 67 ];

  systemd.network.networks."11-microvm" = {
    matchConfig.Name = "vm-*";
    # Attach to the bridge that was configured above
    networkConfig.Bridge = "br0";
  };

  networking.nat = {
    enable = true;
    enableIPv6 = false;
    # The interface with upstream Internet access
    externalInterface = "wlo1"; # TODO This may change from device to device. Hard to mention this declaratively
    # The bridge where you want to provide Internet access
    internalInterfaces = [ "br0" ];
  };
}
