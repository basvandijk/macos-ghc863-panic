{ nixpkgs ? builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/1a88aa9e0cdcbc12acc5cbdc379c0804d208e913.tar.gz";
    sha256 = "076zlppa0insiv9wklk4h45m7frq1vfs43vsa11l8bm5i5qxzk6r";
  }
}:
import nixpkgs {
  overlays = [
    (final: previous: {
      haskell = previous.haskell // {
        packageOverrides = self: super: {
          a = super.callPackage ({ mkDerivation, base, stdenv }:
            mkDerivation {
              pname = "a";
              version = "0.1.0.0";
              src = ./a;
              libraryHaskellDepends = [ base ];
              license = stdenv.lib.licenses.bsd3;
            }
          ) {};
          b = super.callPackage ({ mkDerivation, a, base, stdenv }:
            mkDerivation {
              pname = "b";
              version = "0.1.0.0";
              src = ./b;
              libraryHaskellDepends = [ a base ];
              license = stdenv.lib.licenses.bsd3;
            }
          ) {};
        };
      };
    })
  ];
}
