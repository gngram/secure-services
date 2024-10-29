{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.gcc
    pkgs.python311Full
    pkgs.python311Packages.virtualenv
  ];

  shellHook = ''
    if [ ! -d .venv ]; then
      virtualenv .venv
      source .venv/bin/activate
    else
      source .venv/bin/activate
      pip install sh
    fi
    echo "Welcome to your Python development environment."
  '';
}
