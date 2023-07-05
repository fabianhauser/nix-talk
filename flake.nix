{
  inputs = { nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      packages.${system}.default = let
        name = "nix-talk";
        nodejs = pkgs.nodejs_20;
      in pkgs.stdenv.mkDerivation {
        inherit name;
        buildInputs = with pkgs; [
          nodejs
          plantuml
          google-chrome
          nodePackages.node2nix
        ];
        shellHook = ''
          export PATH="$PWD/node_modules/.bin/:$PATH"
        '';
      };
    };
}
