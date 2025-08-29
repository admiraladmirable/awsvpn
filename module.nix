{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.awsvpnclient;
  defaultVersion = import ./version.nix;

  package = pkgs.callPackage ./package.nix { };
  finalPackage =
    if cfg.version != defaultVersion.version || cfg.sha256 != defaultVersion.sha256 then
      package.overrideVersion { inherit (cfg) version sha256; }
    else
      package;
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
    systemd.services.awsvpnclient = {
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
