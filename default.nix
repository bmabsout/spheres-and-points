{}:

(import ./reflex-platform {}).project ({ pkgs, ... }: {
  packages = {
    frontend = ./frontend;
  };

  overrides = self: super: rec {
    doctest = self.callPackage ./modifiedDeps/doctest/doctest.nix {};  
    ghcjs-three = self.callPackage ./modifiedDeps/ghcjs-three/three.nix {};  
    constructible-v = self.callPackage ./constructible-v.nix {};
  };

  shells = {
    ghcjs = ["frontend"];
  };
})
