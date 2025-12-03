# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    terraform
    terraform-docs
    nodejs_24
    go
  ];

  # Optional: set environment variables
  TF_IN_AUTOMATION = "1";

  # Optional: show shell info
  shellHook = ''
    echo "🚀 Terraform: $(terraform version | head -n1)"
    echo "🚀 Node.js:   $(node --version)"
    echo "🚀 npm:       $(npm --version)"
    echo "🚀 go:        $(go version)"
  '';
}