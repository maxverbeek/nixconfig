{
  flake = {
    description = "Empty flake with a devshell";
    path = ./flake;
  };

  rust = {
    description = "Rust development environment using an overlay";
    path = ./rust;
  };
}
