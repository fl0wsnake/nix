{ config, pkgs, ... }:

{
  systemd.user.services.blue-light-filter = {
    script = ''
      hyprsunset -t 3000
      '';
    path = with pkgs; [ hyprsunset ];
    serviceConfig = {
      Type = "simple";
      Restart = "always"; # Crucial: restarts if the script exits or crashes
      RestartSec = "5s";
      StandardOutput = "journal"; # Log to journal (view with journalctl -u blue-light-filter)
      StandardError = "journal";
      User = "nix"; # Uncomment and set if you want it to run as a specific user
    };
    wantedBy = [ "multi-user.target" ]; # Allows manual starting/stopping, not strictly needed
  };

  systemd.timers.blue-light-filter-start = {
    wantedBy = [ "timers.target" ]; # Ensures the timer is enabled
      timerConfig = {
        OnCalendar = "*-*-* 20:00:00";
        Persistent = true; # If system is off, trigger on boot
          Unit = "blue-light-filter.service";
      };
  };

  systemd.services.blue-light-filter-stopper = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl stop blue-light-filter.service";
# User = "root"; # Stopping typically requires root, unless your service is user-level
    };
  };

  systemd.timers.blue-light-filter-stop = {
    wantedBy = [ "timers.target" ]; # Ensures the timer is enabled
      timerConfig = {
        OnCalendar = "*-*-* 8:00:00";
        Persistent = true;
        Unit = "blue-light-filter-stopper.service";
      };
  };

# Ensure the log file directory exists and is writable by your script if needed
# services.journald.extraConfig = "Storage=persistent"; # For persistent journal logs
}
