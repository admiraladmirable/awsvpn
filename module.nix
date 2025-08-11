{ inputs, system, ... }:

{ lib, config, ... }:

with lib;

let
  cfg = config.programs.awsvpnclient;
  defaultVersion = import ./version.nix;
  package = (
    inputs.self.packages.${system}.awsvpnclient.overrideVersion {
      inherit (cfg) version sha256;
    }
  );
in
{
  options.programs.awsvpnclient = {
    enable = mkEnableOption "Enable AWS VPN Client";
    version = mkOption {
      type = types.str;
      default = defaultVersion.version;
      description = "Version of the AWS VPN Client to build/install";
    };
    sha256 = mkOption {
      type = types.str;
      default = defaultVersion.sha256;
      description = "SHA256 hash of the AWS VPN Client to build/install";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ package ];
    systemd.packages = [ package ];

    # Even though the service already defines this, nixos doesn't pick that up and leaves the service disabled
    systemd.services.AwsVpnClientService.wantedBy = [ "multi-user.target" ];
  };
}
