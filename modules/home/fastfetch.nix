{ config, pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json";

      display = {
        separator = "  ";
        color = {
          title  = "#59b9bd";
          output = "#bdc2ec";
        };
      };

      modules = [
        "break"
        { type = "os";       key = "OS";           keyColor = "#eea88c"; }
        { type = "kernel";   key = " ├  KER";      keyColor = "#eea88c"; }
        { type = "packages"; key = " ├  PKG";      format = "{all}"; keyColor = "#eea88c"; }
        { type = "uptime";   key = " ├  UPT";      keyColor = "#eea88c"; }
        { type = "title";    key = " └  USR";      keyColor = "#eea88c"; }

        "break"
        "break"

        { type = "wm";           key = "WM";       keyColor = "#7ec6e7"; }
        { type = "shell";        key = " ├  SHE";  keyColor = "#7ec6e7"; }
        { type = "terminal";     key = " ├  TER";  keyColor = "#7ec6e7"; }
        { type = "terminalfont"; key = " └  TFO";  keyColor = "#7ec6e7"; }

        "break"
        "break"

        { type = "host";    key = "PC";            keyColor = "#85d485"; }
        { type = "cpu";     key = " ├  CPU";       keyColor = "#85d485"; }
        { type = "memory";  key = " ├  MEM";       keyColor = "#85d485"; }
        { type = "gpu";     key = " ├  GPU";       format = "{1} {2}"; keyColor = "#85d485"; }
        { type = "display"; key = " ├  MON";       format = "{name} {width}x{height}@{refresh-rate}"; keyColor = "#85d485"; }
        { type = "disk";    key = " └  DIS";       keyColor = "#85d485"; }

        "break"
        "break"

        "colors"
      ];
    };
  };
}
