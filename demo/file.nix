{pkgs}: derivation {
  name = "my-very-cool-app";
  system = "x86_64-linux";
  builder = ./build.sh;
  outputs = [ "out" ];
  buildInputs = [ pkgs.bash ];
}
