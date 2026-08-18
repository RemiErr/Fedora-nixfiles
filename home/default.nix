{ config, pkgs, inputs, lib, vars, ... }:

{
  imports = [
    ../modules/home/niri.nix        # 視窗管理器設定與鍵位
    ../modules/home/fish.nix        # Shell
    ../modules/home/foot.nix        # 終端機
    ../modules/home/fastfetch.nix   # 系統資訊
  ];

  # ── 使用者資訊 ───────────────────────────────────────────────────
  home.username      = vars.username;
  home.homeDirectory = vars.homeDirectory;

  # ── 環境變數 ─────────────────────────────────────────────────────
  # 最小安裝、沒有 GNOME，niri 是唯一的圖形 session
  # 只給 niri 圖形環境用的變數（Wayland 專屬）放在
  # modules/home/niri.nix 的 config.kdl environment 區塊，不要放這裡。
  home.sessionVariables = {
    EDITOR = vars.editor;

    # fcitx5 輸入法變數（dnf 安裝，見 ../system/bootstrap.sh）
    XMODIFIERS    = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
  };

  # ── 共用工具套件（使用者層，Nix 管）──────────────────────────────
  home.packages = with pkgs; [
    # Wayland 截圖工具組
    grim
    slurp
    swappy

    wl-clipboard
    libnotify
    xdg-utils
    xdg-user-dirs

    brightnessctl
    playerctl

    btop

    yazi
    imv

    # ── 特殊字型：nixpkgs 才有，或版本比 Fedora 官方源新，交給 Nix 管 ──
    # 常見的 Noto CJK 走 dnf（見 system/bootstrap.sh）
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    material-symbols          # DankMaterialShell 圖示字型
    lxgw-wenkai-screen         # 霞鶩文楷（繁體中文顯示字型）
    maple-mono.NF-unhinted     # Maple Mono NF（foot 預設字型）
  ];

  # ── 字型設定 ────────────────────────────────────────────────────
  fonts.fontconfig.enable = true;

  # ── XDG 使用者目錄 ───────────────────────────────────────────────
  # None

  # ── Git 設定 ─────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user.name  = vars.git.name;
      user.email = vars.git.email;
      init.defaultBranch = "main";
      pull.rebase        = false;
      core.editor        = "nvim";
      diff.tool          = "vimdiff";

      alias = {
        st = "status";
        br = "branch";
        co = "checkout";
        cm = "commit -m";
        ca = "commit -am";
        dc = "diff --cached";
      };
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      "*.env"
      ".direnv"
      "result"
    ];
  };

  # ── Home Manager 管理自身 ────────────────────────────────────────
  programs.home-manager.enable = true;

  home.stateVersion = "26.05";
}
