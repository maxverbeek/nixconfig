{
  fetchPypi,
  buildPythonPackage,
  ...
}:

buildPythonPackage rec {
  pname = "ecida";
  version = "0.0.32";

  src = fetchPypi {
    inherit pname version;
    sha256 = "";
  };

  doCheck = false;

  propagatedBuildInputs = [ ];
}
