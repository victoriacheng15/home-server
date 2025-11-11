{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = [
    pkgs.azure-cli
    pkgs.gh
    pkgs.terraform
  ];

  shellHook = ''
    echo "DevOps environment ready 🧰"
    echo "Azure CLI: $(az --version | head -n 1)"
    echo "Terraform: $(terraform version | head -n 1)"
    echo "GitHub CLI: $(gh --version | head -n 1)"
  '';
}
