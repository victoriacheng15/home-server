# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    terraform
    terraform-docs
    nodejs_24
  ];

  # Optional: set environment variables
  TF_IN_AUTOMATION = "1";

  # Optional: show shell info
  shellHook = ''
    echo "🚀 Dev shell loaded: Terraform + Node.js"
    echo "   Terraform: $(terraform version | head -n1)"
    echo "   Node.js:   $(node --version)"
    echo "   npm:       $(npm --version)"
    echo "   Working directory: $PWD"
  '';
}