{
  flake.modules.homeManager.development =
    { pkgs, ... }:
    let
      python = pkgs.python3.withPackages (ps: [
        ps.bcrypt
        ps.numpy
        ps.pandas
        ps.polars
        ps.pyiceberg
        ps.matplotlib
        ps.seaborn
      ]);
    in
    {
      home.sessionVariables = {
        UV_PYTHON = "${python}/bin/python3";
        UV_PYTHON_DOWNLOADS = "never";
      };

      home.packages = with pkgs; [
        uv
        python
        quarto
        duckdb
      ];
    };
}
