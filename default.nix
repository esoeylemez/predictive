{ mkDerivation, base, containers, smallcheck, stdenv, tasty
, tasty-smallcheck
}:
mkDerivation {
  pname = "predictive";
  version = "0.1.0";
  src = ./.;
  libraryHaskellDepends = [ base containers ];
  testHaskellDepends = [ base smallcheck tasty tasty-smallcheck ];
  homepage = "https://github.com/esoeylemez/predictive";
  description = "Predict the future, backtrack on failure";
  license = stdenv.lib.licenses.asl20;
}
