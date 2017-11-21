{ reflex-platform ? import ../reflex-platform {} , compiler ? "ghcjs"}:

let
  nixpkgs = reflex-platform.nixpkgs;
  config = rec {
    allowUnfree = true;
    allowBroken = true;
    packageOverrides = pkgs: rec {
      haskellPackages = pkgs.haskellPackages.override {
        overrides = self: super: rec {
          doctest = self.callHackage "doctest" "0.13.0" {};
          # cabal = haskellPackages.cabalNoTest;
          bytes = self.callPackage ../reflex-platform/bytes/bytes.nix {};  
          distributive = self.callPackage ../reflex-platform/distributive/distributive.nix {};  
          # JuicyPixels = haskellLib.appendConfigureFlag (super.JuicyPixels) "-fexternal-interpreter";
          # active = haskellLib.appendConfigureFlag (super.active) "-fexternal-interpreter";
          linear = self.callPackage ../reflex-platform/linear/linear.nix {}; 
          frontend = self.callPackage ./frontend.nix;
        };
      };
    };
  };

  pkgs = import <nixpkgs> { inherit config; } // { inherit nixpkgs; };

in
  { frontend = pkgs.haskellPackages.frontend;
  }