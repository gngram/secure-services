{ config, lib, ... }:
let 
  apply-service-configs = configs-dir: {
    services = lib.foldl' (
      services: s:
      let
        svc = builtins.replaceStrings [ ".nix" ] [ "" ] s;
      in
      services
      // lib.optionalAttrs (!builtins.elem "${svc}.service" config.secure-services.exclude) {
        ${svc}.serviceConfig = import "${configs-dir}/${svc}.nix";
      }
    ) { } (builtins.attrNames (builtins.readDir configs-dir));
  };
in
{
  options.secure-services = {
    enable = lib.mkOption {
      description = "Enable common hardened configs.";
      type = lib.types.bool;
      default = false;
    };

    exclude = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
      example = [ "sshd.service" ];
      description = ''
        A list of units to skip when applying hardened systemd service configurations.
        The main purpose of this is to provide a mechanism to exclude specific hardened
        configurations for fast debugging and problem resolution.
      '';
    };
    
    log-level = lib.mkOption {
      description = ''
        Log Level for systemd services.
        Available options: "emerg", "alert", "crit", "err", "warning", "info", "debug"
      '';
      type = lib.types.str;
      default = "info";
    };
  };

  config = {
    systemd = lib.mkMerge [
      # Apply hardened systemd service configurations
      (lib.mkIf config.secure-services.enable (apply-service-configs ./hardened-configs))

      # Set systemd log level
      { services."_global_".environment.SYSTEMD_LOG_LEVEL = config.secure-services.log-level; }
    ];
  };
}
