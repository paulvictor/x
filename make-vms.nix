# TODO , deserves a module of its own
# What all can be done
#   1. Give hostnames
#   2. Assign unique mac(and possibly ip addresses)
#   3. Add hostnames to /etc/host on the host to easily ssh?

{lib, count ? 1, additionalModules ? [], hostNamePrefix, ...}:

with lib;
# return a list of modules which can be called with lib.nixosSystem
builtins.listToAttrs
  (forEach (range 1 count) (i:
      let
        hostName = "${hostNamePrefix}-${toString i}";
        hash = builtins.hashString "sha256" hostName;
        ss = off: builtins.substring off 2 hash;
      in
        lib.nameValuePair
          hostName
          {
            imports = additionalModules ++ [
              ./vms/default.nix
            ];
            systemd.network.enable = true;
            networking.hostName = hostName;

            microvm.interfaces = [{
              type = "tap";
              id = "vm-${hostName}";
              # Locally administered have one of 2/6/A/E in the second nibble.
              mac = "02:${ss 2}:${ss 4}:${ss 6}:${ss 8}:${ss 10}";

            }];
            microvm.shares = [{
              proto = "virtiofs";
              tag = "ro-store-${hostName}";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              readOnly = true;
            }];
          }
    ))

