{
  fetchPypi,
  buildPythonPackage,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "ecida";
  version = "0.0.32";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-UO8UUXbcaFGpzTjTc0O0AYoRi9J9fJHtucvvezbnRPo=";
  };

  doCheck = false;
  format = "pyproject";

  buildInputs = [ setuptools ];
  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [ ];
}
