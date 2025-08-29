{ inputs, system, ... }:

{ lib, config, ... }:

with lib;

let
  cfg = config.programs.awsvpnclient;
  flake = builtins.getFlake (toString ./.);
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
    systemd.services.AwsVpnClientService = {
      description = "AWS VPN Client Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        # Use the service wrapper from the package
        ExecStart = "${package}/bin/awsvpnclient-service-wrapped";
        Restart = "always";
        RestartSec = "1s";
        User = "root";
        # Add better logging
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };
  };
}
