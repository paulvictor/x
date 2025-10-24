{
  description = "Flake for the infra setup";

  nixConfig = {
    extra-substituters = [ "https://microvm.cachix.org" ];
    extra-trusted-public-keys = [ "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys=" ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixlib = {
      url = "github:nix-community/nixpkgs.lib";
    };
  };

  outputs = inputs@{microvm, nixpkgs, flake-utils, ...}:
    let
      inherit (inputs.nixlib) lib;
      supportedFormats =
        lib.remove "all-formats" (lib.attrNames inputs.nixos-generators.nixosModules);
      # An attrset of node type(name) to nixosmodule
      nodes =
        lib.mapAttrs
          (n: _: "${toString ./.}/machines/${n}/default.nix")
          (lib.filterAttrs
            (_: v: v == "directory")
            (builtins.readDir ./machines));
      nomad-servers = import ./make-vms.nix
        { inherit lib; count = 1; hostNamePrefix = "ldr"; };
      nomad-clients = import ./make-vms.nix
        { inherit lib; count = 0; hostNamePrefix = "clnt"; };
      vms =
        lib.mapAttrs
          (hn: config: {inherit config;})
          (nomad-servers // nomad-clients);
      nixosModules =
        lib.mapAttrs
          (n: m:
            [
              ./modules/common.nix
              ./modules/pauls-rpi.nix
              m
            ] ++ lib.optional (n == "vm-host") {microvm.vms = vms;}
           ) nodes;
      formatModules =
        lib.concatMapAttrs
          (node: modules:
            lib.listToAttrs (lib.forEach supportedFormats (format:
              lib.nameValuePair
                "${node}-${format}"
                {
                  imports = modules ++ [inputs.nixos-generators.nixosModules.${format}];
                }
            )))
          nixosModules;
    in {inherit nixosModules;} // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
             "nomad"
           ];
        };
      in {
        legacyPackages = pkgs;
        nixosConfigurations =
          lib.mapAttrs (_: modules:
            nixpkgs.lib.nixosSystem {
              inherit pkgs system modules;
              specialArgs = { inherit inputs; };
            })
            nixosModules;
        packages =
          lib.listToAttrs
            (lib.forEach supportedFormats (format:
              lib.nameValuePair
                format
                (lib.mapAttrs (_: modules:
                  inputs.nixos-generators.nixosGenerate {
                    inherit pkgs system format modules;
                    specialArgs = { inherit inputs; };
                  })
                  nixosModules)
            ));
      }));
}
