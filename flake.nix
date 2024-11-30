{
  description = "A NixOS flake module to secure systemd services";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosModules.SecureServices = import ./modules;
    overlays.default = import ./overlays; 
  };
}

