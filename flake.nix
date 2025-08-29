{
  description = "Flake based AWS VPN Client";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }@inputs:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
        };
      in
      {
        packages = rec {
          awsvpnclient = pkgs.callPackage ./package.nix { };
          default = awsvpnclient;
        };
      }
    ))
    // {
      nixosModules = {
        default = self.nixosModules.awsvpnclient;
        awsvpnclient = import ./module.nix; # Make sure this points to the right file
      };
    };
}
