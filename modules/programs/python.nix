{
  nixos.programs.python =
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
      environment.variables = {
        UV_PYTHON = "${python}/bin/python3";
        UV_PYTHON_DOWNLOADS = "never";
      };

      environment.systemPackages = with pkgs; [
        uv
        python
        quarto
        duckdb
      ];
    };
}
