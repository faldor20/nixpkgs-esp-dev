# When updating to a newer version, check if the version of `esp32*-toolchain-bin.nix` also needs to be updated.
{ rev ? "v4.4.4"
, sha256 ? "sha256-vCvSsqtSwP/udg1BNCnCDnCBsX9nkuq6zEw+Kn1466Q="
, stdenv
, lib
, fetchFromGitHub
, mach-nix, fetchzip
}:

let

  src = fetchzip {
    url= "https://dl.espressif.com/github_assets/espressif/esp-idf/releases/download/${rev}/esp-idf-${rev}.zip";
    hash=sha256;
  };

  pythonEnv =
    let
      # Remove things from requirements.txt that aren't necessary and mach-nix can't parse:
      # - Comment out Windows-specific "file://" line.
      # - Comment out ARMv7-specific "--only-binary" line.
      requirementsOriginalText = builtins.readFile "${src}/requirements.txt";
      requirementsText = builtins.replaceStrings
        [ "file://" "--only-binary" ]
        [ "#file://" "#--only-binary" ]
        [ "bitstring>=3.1.6,<4" "bitstring==3.1.9"]
        requirementsOriginalText;
    in
    mach-nix.mkPython
      {
        requirements = requirementsText;
      };
in
stdenv.mkDerivation rec {
  pname = "esp-idf";
  version = rev;

inherit src;

  # This is so that downstream derivations will have IDF_PATH set.
  setupHook = ./setup-hook.sh;

  propagatedBuildInputs = [
    # This is so that downstream derivations will run the Python setup hook and get PYTHONPATH set up correctly.
    pythonEnv.python
  ];

  installPhase = ''
    mkdir -p $out
    cp -r $src/. $out/

    # Link the Python environment in so that in shell derivations, the Python
    # setup hook will add the site-packages directory to PYTHONPATH.
    ln -s ${pythonEnv}/lib $out/
  '';
}
