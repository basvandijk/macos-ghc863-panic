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
          a = super.callCabal2nix "a" ./a {};
          b = super.callCabal2nix "b" ./b {};
        };
      };
    })
  ];
}
