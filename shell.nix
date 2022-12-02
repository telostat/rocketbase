let
  sources = import ./nix/sources.nix { };
  pkgs = import sources.nixpkgs { };

  devDependencies = [
    pkgs.rPackages.devtools
    pkgs.rPackages.languageserver
    pkgs.rPackages.roxygen2
  ];

  libDependencies = [
    pkgs.rPackages.crul
    pkgs.rPackages.jsonlite
    pkgs.rPackages.R6
  ];

  thisR = pkgs.rWrapper.override {
    packages = devDependencies ++ libDependencies;
  };
in
pkgs.mkShell {
  buildInputs = [
    thisR
    pkgs.git-chglog
    pkgs.pocketbase
  ];

  shellHook = ''
    export ROCKETBASE_DIR="./tmp/pg_data"
    alias pocketbase-reset="find ./tmp/pg_data -type f -delete"
    alias pocketbase-serve="pocketbase serve --dir ./tmp/pg_data"
  '';
}
