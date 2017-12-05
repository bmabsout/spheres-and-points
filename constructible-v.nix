
{ mkDerivation, stdenv, fetchFromGitHub, linear
}:
mkDerivation {
  pname = "constructible-v";
  version = "0.1.0.0";
  src = fetchFromGitHub {
          owner="bmabsout";
          repo="constructible-v";
          rev="828fcbbbe4dad511a6dbd8e3ed329dbeb17bb1cb";
          sha256="0fb96dxmmvz5rq6gishyipsgrf3lvyvy4rc3i50qm0v5qsjc8bii";
  };
  libraryHaskellDepends = [linear];
  description = "Please see README.md";
  license = stdenv.lib.licenses.bsd3;
}
