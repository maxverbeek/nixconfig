{ lib, bundlerEnv, ruby }:

bundlerEnv {
  pname = "rubocop";

  inherit ruby;
  gemdir = ./.;

  meta = with lib; {
    description = "RuboCop";
    platforms = platforms.unix;
  };
}
