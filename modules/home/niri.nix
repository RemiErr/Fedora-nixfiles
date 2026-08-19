{ config, pkgs, lib, ... }:

{
  # ── DankMaterialShell systemd 服務的環境變數 override ─────────────
  # dms 是由 Fedora 套件自帶的 /usr/lib/systemd/user/dms.service 啟動
  # 不要直接改 /usr/lib 底下那個檔案（套件升級會蓋掉）
  # 使用 drop-in 疊加環境變數
  # 目的：避免 fcitx5 附加到 dms 自己的 QML 輸入框、搶輸入焦點。
  xdg.configFile."systemd/user/dms.service.d/fcitx5-override.conf".text = ''
    [Service]
    Environment=QT_IM_MODULE=none
    Environment=XMODIFIERS=@im=none
  '';

  # ── XDG Desktop Portal 選擇順序 ──────────────────────────────────
  # 後端套件（xdg-desktop-portal-gtk / -gnome）由 dnf 安裝
  # （見 ../../system/bootstrap.sh），這裡只管哪個後端優先。
  xdg.configFile."xdg-desktop-portal/niri-portals.conf".text = ''
    [preferred]
    default=gnome;gtk
    org.freedesktop.impl.portal.Secret=gnome-keyring
  '';

  # ── niri 設定檔（KDL 格式）──────────────────────────────────────
  # 文件：https://github.com/YaLTeR/niri/wiki/Configuration:-Overview
  # 查詢可用螢幕名稱：niri msg outputs
  # 查詢可用按鍵名稱：niri msg event-stream （按鍵時查看輸出）
  xdg.configFile."niri/config.kdl".text = ''
    // ── 輸入裝置 ──────────────────────────────────────────────────
    input {
        keyboard {
            xkb {
                layout "us"
                // fcitx5 處理中文（注音）輸入，此處維持 us 佈局
            }
            repeat-delay 500
            repeat-rate  30
        }

        touchpad {
            tap                         // 點擊即按下
            natural-scroll              // 自然捲動
            accel-speed 0.2
            accel-profile "adaptive"
            scroll-method "two-finger"
            dwt                         // 打字時停用（disable while typing）
        }

        mouse {
            accel-speed 0.0
            accel-profile "flat"
        }

        focus-follows-mouse max-scroll-amount="0%"
        warp-mouse-to-focus
    }

    // ── 螢幕開關事件 ──────────────────────────────────────────────
    switch-events {
        lid-close { spawn "dms" "ipc" "call" "lock" "lock"; }
    }

    // ── 環境變數（只套用到 niri 這個 session）─────────────────────
    // 最小安裝、沒有 GNOME，niri 是唯一的圖形 session，但這裡的變數
    // 只會傳給 niri 自己啟動的行程，不會外溢到 TTY 登入殼層或
    // dms-greeter 本身——所以 Wayland 專屬的變數還是寫在這裡，不要
    // 放進 home/default.nix 的 home.sessionVariables
    environment {
        NIXOS_OZONE_WL "1"                      // Electron/Chromium（若透過 Nix 安裝）
        MOZ_ENABLE_WAYLAND "1"                  // Firefox
        QT_QPA_PLATFORM "wayland;xcb"            // Qt，xcb 後備交給 xwayland-satellite
        QT_WAYLAND_DISABLE_WINDOWDECORATION "1" // 讓 niri 管理視窗裝飾
        GDK_BACKEND "wayland,x11,*"              // GTK
        SDL_VIDEODRIVER "wayland"                // SDL2 遊戲
        CLUTTER_BACKEND "wayland"                // Clutter
        XDG_SESSION_TYPE "wayland"
        XDG_CURRENT_DESKTOP "niri"
    }

    // ── 螢幕設定 ────────────────────────────────────────────────
    // 查詢螢幕名稱：niri msg outputs
    // 縮放比例 1.25 適合 2K 螢幕，1.5 適合 4K
    output "eDP-1" {
        scale 1.0
        // mode "1920x1080@60.000"  // 取消注解以強制指定解析度
    }
    // 外接螢幕範例：
    // output "HDMI-A-1" {
    //     scale 1.0
    //     position x=1920 y=0
    // }

    // ── 版面配置 ────────────────────────────────────────────────
    layout {
        gaps 10
        center-focused-column "never"
        always-center-single-column

        preset-column-widths {
            proportion 0.333
            proportion 0.5
            proportion 0.667
            proportion 1.0
        }

        default-column-width {
            proportion 0.5
        }

        focus-ring {
            width 2
            active-color   "rgba(20,19,17,0.35)"
            inactive-color "rgba(20,19,17,0.85)"
        }

        border {
            off
        }

        shadow {
            on
            softness 20
            spread 2
            offset x=-4 y=-4
            color "rgba(0, 0, 0, 0.7)"
        }

        struts {
            left   6
            right  6
            top    8
            bottom 10
        }
    }

    // ── 啟動時執行 ──────────────────────────────────────────────
    // fcitx5、xwayland-satellite、polkit 認證代理都由 dnf 裝到系統層
    // （見 ../../system/bootstrap.sh），niri 只負責在自己的 session 裡
    // 把它們啟動起來。
    spawn-at-startup "fcitx5" "-d" "--replace"
    spawn-at-startup "xwayland-satellite"
    spawn-at-startup "/usr/libexec/polkit-gnome-authentication-agent-1"

    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    animations {
        slowdown 0.98
        workspace-switch {
            spring damping-ratio=0.82 stiffness=400 epsilon=0.0001
        }
        horizontal-view-movement {
            spring damping-ratio=0.84 stiffness=400 epsilon=0.0001
        }
        window-open {
            spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
        }
        window-close {
            spring damping-ratio=0.8 stiffness=400 epsilon=0.0001
        }
        window-movement {
            spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
        }
        window-resize {
            spring damping-ratio=0.9 stiffness=500 epsilon=0.0001
        }
    }

    // ── 視窗通用規則 ────────────────────────────────────────────
    window-rule {
        geometry-corner-radius 20
        clip-to-geometry true
    }

    // Firefox 畫中畫
    window-rule {
        match app-id=r#"firefox"# title=r#"Picture-in-Picture"#
        open-floating true
    }

    // ── 按鍵綁定 ────────────────────────────────────────────────
    // Mod = Super/Windows 鍵
    // 查看所有可用 action：niri msg action list
    // DankMaterialShell 的 IPC 指令：dms ipc call <target> <action>
    // 文件：https://danklinux.com/docs/dankmaterialshell/keybinds-ipc

    binds {
        // ── 應用程式 ─────────────────────────────────────────
        Mod+Return  { spawn "foot"; }
        Mod+D       { spawn-sh "dms ipc call spotlight toggle"; }
        Mod+Ctrl+L  { spawn-sh "dms ipc call lock lock"; }
        Mod+Shift+E { spawn-sh "dms ipc call powermenu toggle"; }
        Mod+N       { spawn-sh "dms ipc call notifications toggle"; }

        // 截圖（grim + slurp）
        Print           { screenshot; }
        Ctrl+Print      { screenshot-screen; }
        Alt+Print       { screenshot-window; }
        Mod+Shift+S     { spawn "sh" "-c" "grim -g \"$(slurp)\" - | swappy -f -"; }

        // 剪貼簿歷史（DankMaterialShell 內建）
        Mod+V { spawn-sh "dms ipc call clipboard toggle"; }

        // ── 視窗焦點（vim 鍵 + 方向鍵）──────────────────────
        Mod+H           { focus-column-left; }
        Mod+L           { focus-column-right; }
        Mod+J           { focus-window-down; }
        Mod+K           { focus-window-up; }
        Mod+Left        { focus-column-left; }
        Mod+Right       { focus-column-right; }
        Mod+Down        { focus-window-down; }
        Mod+Up          { focus-window-up; }

        // 焦點跳到欄首/欄尾
        Mod+Home        { focus-column-first; }
        Mod+End         { focus-column-last; }

        // ── 視窗移動 ─────────────────────────────────────────
        Mod+Shift+H     { move-column-left; }
        Mod+Shift+L     { move-column-right; }
        Mod+Shift+J     { move-window-down; }
        Mod+Shift+K     { move-window-up; }
        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Down  { move-window-down; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Home  { move-column-to-first; }
        Mod+Shift+End   { move-column-to-last; }

        // ── 視窗大小 ─────────────────────────────────────────
        Mod+R           { switch-preset-column-width; }
        Mod+Shift+R     { reset-window-height; }
        Mod+F           { maximize-column; }
        Mod+Shift+F     { fullscreen-window; }
        Mod+C           { center-column; }
        Mod+Minus       { set-column-width "-10%"; }
        Mod+Equal       { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        // ── 視窗管理 ─────────────────────────────────────────
        Mod+Q           { close-window; }
        Mod+T           { toggle-window-floating; }
        Mod+Shift+C     { consume-window-into-column; }
        Mod+Shift+X     { expel-window-from-column; }

        // ── 工作區 ───────────────────────────────────────────
        Mod+1           { focus-workspace 1; }
        Mod+2           { focus-workspace 2; }
        Mod+3           { focus-workspace 3; }
        Mod+4           { focus-workspace 4; }
        Mod+5           { focus-workspace 5; }
        Mod+6           { focus-workspace 6; }
        Mod+7           { focus-workspace 7; }
        Mod+8           { focus-workspace 8; }
        Mod+9           { focus-workspace 9; }
        Mod+Shift+1     { move-column-to-workspace 1; }
        Mod+Shift+2     { move-column-to-workspace 2; }
        Mod+Shift+3     { move-column-to-workspace 3; }
        Mod+Shift+4     { move-column-to-workspace 4; }
        Mod+Shift+5     { move-column-to-workspace 5; }
        Mod+Shift+6     { move-column-to-workspace 6; }
        Mod+Shift+7     { move-column-to-workspace 7; }
        Mod+Shift+8     { move-column-to-workspace 8; }
        Mod+Shift+9     { move-column-to-workspace 9; }
        Mod+Tab         { focus-workspace-previous; }
        Mod+Page_Down   { focus-workspace-down; }
        Mod+Page_Up     { focus-workspace-up; }
        Mod+Ctrl+Down   { move-column-to-workspace-down; }
        Mod+Ctrl+Up     { move-column-to-workspace-up; }

        // ── 系統媒體 / 音量 / 亮度（DankMaterialShell IPC）────
        XF86AudioRaiseVolume  allow-when-locked=true { spawn-sh "dms ipc call audio increment"; }
        XF86AudioLowerVolume  allow-when-locked=true { spawn-sh "dms ipc call audio decrement"; }
        XF86AudioMute         allow-when-locked=true { spawn-sh "dms ipc call audio mute"; }
        XF86AudioMicMute      { spawn-sh "dms ipc call mic mute"; }
        XF86MonBrightnessUp   { spawn-sh "dms ipc call brightness increment"; }
        XF86MonBrightnessDown { spawn-sh "dms ipc call brightness decrement"; }
        XF86AudioPlay         { spawn-sh "dms ipc call mpris playPause"; }
        XF86AudioNext         { spawn-sh "dms ipc call mpris next"; }
        XF86AudioPrev         { spawn-sh "dms ipc call mpris previous"; }

        // ── niri 說明 ────────────────────────────────────────
        Mod+Shift+Slash { show-hotkey-overlay; }
        Mod+Escape      { spawn "sh" "-c" "niri msg action quit --skip-confirmation"; }
    }
  '';
}
