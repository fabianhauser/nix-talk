{pkgs ? import <nixpkgs> {
    inherit system;
  }, system ? builtins.currentSystem,
nodejs ? pkgs.nodejs-16_x,
}:

let
  nodePackages = import ./default.nix {
    inherit pkgs system nodejs;
  };
in nodePackages // {
  "playwright-chromium-1.35.1" = nodePackages."playwright----chromium-1.35.1".override {
    dontNpmInstall = true;
  };
  "playwright-core-1.35.1" = nodePackages."playwright----core-1.35.1".override {
    dontNpmInstall = true;
  };
}
