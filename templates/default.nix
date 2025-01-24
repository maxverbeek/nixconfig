{
  flake = {
    description = "Empty flake with a devshell";
    path = ./flake;
  };

  rust = {
    description = "Rust development environment using an overlay";
    path = ./rust;
  };

  python = {
    description = "Python development with pip in a venv (needs nix-ld for C packages)";
    path = ./python;
  };
}
