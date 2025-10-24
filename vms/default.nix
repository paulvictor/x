{config, ...}:
{
  imports = [
    ../modules/common.nix
  ];
  microvm.hypervisor = "qemu";
  microvm.mem = 256;

}
