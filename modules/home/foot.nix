{ pkgs, ... }:

{
  programs.foot = {
    enable = pkgs.stdenv.isLinux;
    server.enable = true;

    settings = {
      main = {
        term             = "foot";
        font             = "Maple Mono NF:size=13";
        dpi-aware        = "no";
        resize-keep-grid = "no";
        pad              = "10x10"; # 水平x垂直
      };

      cursor = {
        style = "block";
        blink = "no";
        beam-thickness = "1.5";
      };

      mouse = {
        hide-when-typing = "yes";
        alternate-scroll-mode = "yes";
      };

      # 新版 foot 把 [colors] 拆成 [colors-dark]/[colors-light]
      colors-dark = {
        alpha  = "0.85";
        cursor = "141311 FFB4AB";  # text-on-cursor  cursor-bg

        background           = "141311";
        foreground           = "CFC6A9";
        selection-foreground = "211F1D";
        selection-background = "CCC6B8";
        urls                 = "62938F";

        # ── 一般色彩 ────────────────────────────────────────────
        regular0 = "211F1D";
        regular1 = "A66359";
        regular2 = "6F895C";
        regular3 = "AB9349";
        regular4 = "627394";
        regular5 = "93627E";
        regular6 = "62938F";
        regular7 = "CCC6B8";

        # ── 亮色彩 ──────────────────────────────────────────────
        bright0 = "49473D";
        bright1 = "FFB4AB";
        bright2 = "BFCAB4";
        bright3 = "CFC6A9";
        bright4 = "A9B5C6";
        bright5 = "C6A9BA";
        bright6 = "ADC2C1";
        bright7 = "DDD7C3";
      };

      scrollback = {
        lines = 10000;
      };
    };
  };
}
