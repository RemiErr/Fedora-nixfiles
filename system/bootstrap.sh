#!/usr/bin/env bash
# fedora-nix/system/bootstrap.sh
#
# 目標：Fedora 43 最小安裝（無 GNOME/GDM）。
# 這支腳本補齊 niri + DankMaterialShell 這套方案要用到的系統層東西：
# niri 本體、輸入法、音訊、portal、polkit 認證代理、CJK 字型
#
# 用法：sudo bash system/bootstrap.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "請用 sudo 執行：sudo bash $0" >&2
  exit 1
fi

echo "==> 更新 dnf 套件索引"
dnf makecache

echo "==> 安裝 niri（Fedora 官方套件庫已收錄，會自動帶入 xwayland-satellite 依賴）"
dnf install -y niri

echo "==> 安裝網路管理（最小安裝可能沒有預裝）"
if ! rpm -q NetworkManager >/dev/null 2>&1; then
  dnf install -y NetworkManager
  systemctl enable --now NetworkManager
else
  echo "    已安裝，略過。"
fi

echo "==> 安裝音訊（PipeWire + WirePlumber，最小安裝不會預裝）"
# 音量元件、niri 設定裡的 XF86Audio* 鍵綁都要用
dnf install -y pipewire pipewire-pulseaudio pipewire-alsa wireplumber

echo "==> 安裝輸入法（fcitx5 + 新酷音注音）"
dnf install -y fcitx5 fcitx5-chewing fcitx5-gtk3 fcitx5-gtk4 fcitx5-qt fcitx5-configtool

echo "==> 安裝 XDG Desktop Portal 後端與 polkit 認證代理"
# niri 的檔案選擇/截圖對話框要用 portal；niri 沒有內建 polkit agent
# （不像 GNOME Shell 會自帶一個），要另外裝一個給需要提權的 GUI 操作用。
dnf install -y xdg-desktop-portal-gtk xdg-desktop-portal-gnome gnome-keyring polkit-gnome

echo "==> 安裝 CJK 字型（中文顯示）"
dnf install -y google-noto-sans-cjk-ttc-fonts google-noto-serif-cjk-ttc-fonts

echo "==> 設定時區與 locale"
timedatectl set-timezone Asia/Taipei
localectl set-locale LANG=zh_TW.UTF-8

echo ""
echo "==> 系統層安裝完成。接下來（用你自己的帳號執行，不要 sudo）："
echo ""
echo "    1) 安裝 DankMaterialShell（官方安裝精靈，會自動偵測 Fedora）："
echo "         curl -fsSL https://install.danklinux.com | sh"
echo "       精靈跑到登入畫面（greeter）那一步時選擇啟用 dms-greeter，"
echo "       它會自動處理 greetd 安裝、/etc/greetd/config.toml、權限、"
echo "       開機啟用——不需要再手動裝。手動流程見 ../README.md 備援。"
echo ""
echo "    2) 安裝 Nix 並套用 home-manager 設定，見 ../README.md"
