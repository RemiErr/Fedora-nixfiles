# Fedora-nixfiles

採用以下方案 ：
- **Fedora-43**： 最小安裝（無 GNOME/GDM）
- **Fedora dnf**：管理系統層（含 niri / DankMaterialShell / fcitx5）
- **Nix/home-manager**：管理使用者層 dotfiles（含 niri 設定檔）。

Nix 作為主要的套件管理器以及管理使用者設定，DankMaterialShell + Niri 作為桌面環境。

## 分工

| 層級                                      | 管理者                                                                  | 內容                                                                                                                                       |
| ----------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| niri 執行檔 / 系統基礎                    | **dnf**（[system/bootstrap.sh](system/bootstrap.sh)）                   | niri（含 xwayland-satellite）、NetworkManager、PipeWire/WirePlumber、fcitx5+新酷音注音、xdg-desktop-portal 後端、polkit 認證代理、CJK 字型 |
| DankMaterialShell（Quickshell）+ 登入畫面 | **官方安裝精靈**（`curl -fsSL https://install.danklinux.com \| sh`）    | `dms` 執行檔、Quickshell 執行環境、**dms-greeter**（greetd 登入畫面，精靈裡勾選即可自動裝好）                                              |
| 使用者設定 / dotfiles / 開發環境          | **Nix / home-manager**（[home/](home) + [modules/home/](modules/home)） | **niri 設定檔（KDL）**、fish、foot、fastfetch、CLI 工具、特殊字型                                                                          |

`bootstrap.sh` 假設你是從最小安裝開始，所以**會**額外裝 NetworkManager、PipeWire/WirePlumber 這些 Fedora Workstation 出廠就有、但最小安裝不一定有的基礎服務；如果你的系統已經有這些（例如從 Fedora Server 裝的），`dnf install` 對已安裝套件是安全的空操作，不會重複設定。

## 安裝流程

### 1. 系統層（dnf）

```bash
git clone <this-repo-or-copy-the-folder> ~/.config/fedora-nix
cd ~/.config/fedora-nix
sudo bash system/bootstrap.sh
```

### 2. 安裝 DankMaterialShell + 登入畫面

用你自己的帳號執行（不要 `sudo`）：

```bash
curl -fsSL https://install.danklinux.com | sh
```

使用 DankMaterialShell 官方的安裝腳本，**跑到登入畫面這一步時選擇啟用 dms-greeter**。

> [!TIP]
> 執行來路不明的 `curl | sh` 前建議先看一眼腳本內容：`curl -fsSL https://install.danklinux.com | less`。

> [!NOTE]
> **手動安裝 dms-greeter（備援）**：如果精靈跳過這步、或你想事後再補裝，官方文件（[danklinux.com/docs/dankgreeter](https://danklinux.com/docs/dankgreeter/installation)）給的手動流程是：
> ```bash
> sudo dnf copr enable avengemedia/danklinux
> sudo dnf install dms-greeter
> dms greeter enable   # 寫 /etc/greetd/config.toml、停用衝突的顯示管理器、啟用 greetd 服務
> dms greeter sync     # 把你的 DMS 佈景主題同步到登入畫面，並把你的帳號加進 greeter 群組
> ```
> `dms greeter enable`/`sync` 需要 DMS 本身已經裝好（見上一步），且視情況可能會自己跳出提權密碼提示。  
> 跑完用 `dms greeter status` 確認狀態，`sync` 完通常要登出重進（群組異動）或重開機才會生效。

### 3. 安裝 Nix

推薦用 [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer)（對 systemd 處理得比較好，且預設啟用 flakes）：

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

或用官方安裝腳本，需自行啟用 flakes：

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

安裝完後**重新登入 shell**讓 `/nix` 相關環境變數生效，用 `nix --version` 確認可用。

### 4. 填寫 variables.nix

```bash
cp variables.nix.example variables.nix
nano variables.nix   # username / hostname / homeDirectory / git 填入你的值
```

`variables.nix` 已在 `.gitignore` 排除，不會被 commit。

### 5. 第一次套用 home-manager

第一次執行時 `home-manager` 指令還沒進到 profile 裡，要用 `nix run` 觸發：

```bash
nix run home-manager/release-26.05 -- switch --flake .#<username>@<hostname>
```

之後就能直接用 `home-manager switch --flake .#<username>@<hostname>`，或用 fish 裡設好的別名：

```fish
hm    # 等同 home-manager switch --flake .#<username>@<hostname>
```

### 6. 設定 fish 為預設 shell（可選）

home-manager 只會把 fish 裝進 Nix profile，**不會**改掉帳號的登入 shell（standalone 模式沒有系統層可以碰 `/etc/passwd`）。要讓終端機打開就是 fish，得自己手動跑一次：

```bash
which fish                        # 確認路徑，通常是 ~/.nix-profile/bin/fish
echo "$(which fish)" | sudo tee -a /etc/shells
chsh -s "$(which fish)"
```

下次登入或重開終端機才會生效，foot 本身是純 Wayland 終端機，只能在 niri session 裡跑。  
niri 設定裡已經用鍵綁 `Mod+Return` 開 foot（見 [modules/home/niri.nix](modules/home/niri.nix)）。

### 7. 第一次登入注音輸入法

fcitx5 由 niri 設定檔的 `spawn-at-startup "fcitx5" "-d" "--replace"` 自動啟動（見 [modules/home/niri.nix](modules/home/niri.nix)），但**第一次**通常要手動確認新酷音有被加進輸入法清單：

```bash
fcitx5-configtool
```

在「輸入法」分頁把「Chewing」（新酷音）加進去，預設切換鍵是 `Ctrl+Space`。之後這個選擇會存在 `~/.config/fcitx5/profile`，不需要每次重設。

### 8. 登入

重開機後會看到 dms-greeter 的登入畫面，輸入帳號密碼即可進入 niri。

## 日常維護

| 指令                                             | 作用                                                                                        |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------- |
| `update`（fish 函式）                            | `dnf upgrade --refresh` — 更新系統層套件                                                    |
| `hm`（fish 函式）                                | `home-manager switch --flake .#user@host` — 套用使用者層設定（niri 設定檔在內，執行檔不在） |
| `curl -fsSL https://install.danklinux.com \| sh` | 重新執行以升級 DankMaterialShell / dms-greeter                                              |
| `flakeup`（fish alias）                          | `nix flake update` — 更新 flake inputs（nixpkgs / home-manager）                            |
| `gc`（fish alias）                               | `nix-collect-garbage -d` — 清除舊的 Nix generations                                         |
| `gens`（fish alias）                             | `home-manager generations` — 列出 home-manager 世代，方便回滾                               |