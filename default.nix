{ mkDerivation, base, containers, stdenv }:
mkDerivation {
  pname = "predictive";
  version = "0.1.0";
  src = ./.;
  libraryHaskellDepends = [ base containers ];
  homepage = "https://github.com/esoeylemez/predictive";
  description = "Predict the future, backtrack on failure";
  license = stdenv.lib.licenses.bsd3;
}
