GHC Panic
=========

This repo is a minimal test-case for the GHC panic described in [GHC
issue #16130](https://ghc.haskell.org/trac/ghc/ticket/16130) which is triggered
when building a static library from a Nix builder:

    > ghc -staticlib ...
    ghc: panic! (the 'impossible' happened)
          (GHC version 8.6.3 for x86_64-apple-darwin):
                Data.Binary.Get.runGet at position 8: Invalid magic number "INPUT(-l"
        CallStack (from HasCallStack):
          error, called at libraries/binary/src/Data/Binary/Get.hs:351:5 in binary-0.8.6.0:Data.Binary.Get

To reproduce execute `nix-build -A haskellPackages.b`.


Design
======

* We have two Haskell packages: `a` and `b` where `b` depends on `a`.

* `a` exposes an empty module `A`.

* `b` exposes a minimal module `B` which justs imports `A`.

* `a` specifies to link with `libc++` (`extra-libraries: c++`).

* Building `b` with Nix triggers the panic.


Observations
============

Some observations:

* This only happens on MacOS, using GHC-8.6.3 and building with
  `nix-build`. Note that the Nix builder enables static libraries by default.

* The panic can also be triggered from inside a `nix-shell`:

      nix-shell -A haskellPackages.b.env --run \
        'cd b; cabal configure --enable-static; cabal build'

* The build completes successfully on Linux.

* The build completes successfully with GHC < 8.6 like GHC-8.4.4:
  `nix-build -A haskell.packages.ghc844.b`

* When I remove the `extra-libraries: c++` field in `a.cabal` the build
  completes successfully.

* The build completes successfully when not using Nix. I tested with building
  the `a` and `b` packages using the Haskell Platform for MacOS. They build
  without problems. Here's the command that's executed for building the static
  library:

        /usr/local/bin/ghc \
          -staticlib \
          -this-unit-id b-0.1.0.0-1072cnXtut6ENJ494A3pWo \
          -hide-all-packages \
          -no-auto-link-packages \
          -package-db dist/package.conf.inplace \
          -package-id a-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1 \
          -package-id base-4.12.0.0 \
          dist/build/B.o \
          -o dist/build/libHSb-0.1.0.0-1072cnXtut6ENJ494A3pWo-ghc8.6.3.a

* Compare the previous to the following similar command that is run from a Nix
  builder:

        /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3/bin/ghc \
          -staticlib \
          '-L/nix/store/jv40yw2ny28nnpbf860aaqq1dhga0f0r-libc++-5.0.2/lib' \
          '-L/nix/store/hgqs9r48niq50xzvgnz7prbykizpy4mk-libc++abi-5.0.2/lib' \
          -L/nix/store/r6aijfn3pi3k11rddrw9531pwglhrblr-compiler-rt-5.0.2/lib \
          -L/nix/store/0lqb3vjib31xyr8iadc8rib9bpl8mf5m-ncurses-6.1-20181027/lib \
          -L/nix/store/0jn6j8ya9zffqd427rjhalhrfqcldalf-gmp-6.1.2/lib \
          -L/nix/store/r0wvw1pk9sdylb308zn4hp5j0r6v6ak6-libiconv-osx-10.11.6/lib \
          -this-unit-id b-0.1.0.0-1072cnXtut6ENJ494A3pWo\
          -hide-all-packages \
          -no-auto-link-packages \
          -no-user-package-db \
          -package-db /private/tmp/nix-build-b-0.1.0.0.drv-0/package.conf.d \
          -package-db dist/package.conf.inplace \
          -package-id a-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1 \
          -package-id base-4.12.0.0 \
          dist/build/B.o \
          -o dist/build/libHSb-0.1.0.0-1072cnXtut6ENJ494A3pWo-ghc8.6.3.a \
          -j1
        ghc: panic! (the 'impossible' happened)
          (GHC version 8.6.3 for x86_64-apple-darwin):
                Data.Binary.Get.runGet at position 8: Invalid magic number "INPUT(-l"
        CallStack (from HasCallStack):
          error, called at libraries/binary/src/Data/Binary/Get.hs:351:5 in binary-0.8.6.0:Data.Binary.Get

  The most notable difference are all the included libraries. 
  However, adding all the `-L...` arguments to the `ghc -staticlib` command 
  from the Haskell Platform doesn't trigger the panic.

* Note that even though GHC panics the static lib
  `libHSb-0.1.0.0-1072cnXtut6ENJ494A3pWo.a` is created. You can observe this by
  invoking `nix-build` with `--keep-failed` so that the build directory is kept
  after a failure.

* Unsurprisingly, when I disable building a static library for `b`
  (`enableStaticLibraries = false;`) the build succeeds.


Impact
======

* Packages that depend on the
  [double-conversion](http://hackage.haskell.org/package/double-conversion)
  package fail to build because `double-conversion` specifies:
  `extra-libraries: c++`.

* Packages that depend on `opencv` like `opencv-extra` [fail to
  build](https://github.com/LumiGuide/haskell-opencv/issues/138)
  because `opencv` specifies: `extra-libraries: c++`.

* I have seen two private code bases that have packages that specify
  `extra-libraries: c++`. This means that any code that depends on
  those packages fail to build.

