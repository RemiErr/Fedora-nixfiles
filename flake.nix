{
  description = "Fedora 43 + Niri + DankMaterialShell + home-manager (standalone) dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};
      vars   = import ./variables.nix;
    in
    {
      # ── 獨立 Home Manager（Fedora 系統上使用，無 nixosConfigurations）──
      homeConfigurations."${vars.username}@${vars.hostname}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs vars; };
        modules = [ ./home/default.nix ];
      };
    };
}
