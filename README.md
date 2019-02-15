GHC Panic
=========

This repo is a minimal test-case for the following GHC panic described in
[GHC issue #16130](https://ghc.haskell.org/trac/ghc/ticket/16130).

    ghc: panic! (the 'impossible' happened)
          (GHC version 8.6.3 for x86_64-apple-darwin):
                Data.Binary.Get.runGet at position 8: Invalid magic number "INPUT(-l"
        CallStack (from HasCallStack):
          error, called at libraries/binary/src/Data/Binary/Get.hs:351:5 in binary-0.8.6.0:Data.Binary.Get

To reproduce execute `nix-build -A haskellPackages.b`.
A full log is copied below.


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

* This only happens on MacOS. The build completes successfully on Linux.

* This only happens when building with GHC-8.6.3.

* The build completes successfully with GHC < 8.6 like GHC-8.4.4:
  `nix-build -A haskell.packages.ghc844.b`

* When I remove the `extra-libraries: c++` field in `a.cabal` the build
  completes successfully.

* When I build manually using `cabal` the build completes successfully:

  `nix-shell -A haskellPackages.b.env --run 'cd b; cabal build'`

  So it seems to have something to do with how `nixpkgs` builds Haskell packages
  with GHC-8.6 on MacOS.


Full log
========

    > nix-build -A haskellPackages.b
    these derivations will be built:
      /nix/store/1v6li3mshvi3c44lcqdsvymjjmrcna42-a-0.1.0.0.drv
      /nix/store/w136ni99zv0vny12wx4p10wlycv1alap-b-0.1.0.0.drv
    building '/nix/store/1v6li3mshvi3c44lcqdsvymjjmrcna42-a-0.1.0.0.drv'...
    setupCompilerEnvironmentPhase
    Build with /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3.
    unpacking sources
    unpacking source archive /nix/store/7yjdbhcbxbxsk2zdwc8lp6j45b1s6v1b-a
    source root is a
    patching sources
    compileBuildDriverPhase
    setupCompileFlags: -package-db=/private/tmp/nix-build-a-0.1.0.0.drv-0/setup-package.conf.d -j1 -threaded
    [1 of 1] Compiling Main             ( /nix/store/4mdp8nhyfddh7bllbi7xszz7k9955n79-Setup.hs, /private/tmp/nix-build-a-0.1.0.0.drv-0/Main.o )
    Linking Setup ...
    configuring
    configureFlags: --verbose --prefix=/nix/store/q3npinbdm45vnnly5cn8vpd9r32k3h6l-a-0.1.0.0 --libdir=$prefix/lib/$compiler --libsubdir=$abi/$libname --docdir=/nix/store/hmyd21lrdl02ckz9xisy3d0ijrmf1z53-a-0.1.0.0-doc/share/doc/a-0.1.0.0 --with-gcc=clang --package-db=/private/tmp/nix-build-a-0.1.0.0.drv-0/package.conf.d --ghc-option=-j1 --disable-split-objs --enable-library-profiling --profiling-detail=exported-functions --disable-profiling --enable-shared --disable-coverage --enable-static --disable-executable-dynamic --enable-tests --disable-benchmarks --enable-library-vanilla --enable-library-for-ghci --extra-include-dirs=/nix/store/jv40yw2ny28nnpbf860aaqq1dhga0f0r-libc++-5.0.2/include --extra-lib-dirs=/nix/store/jv40yw2ny28nnpbf860aaqq1dhga0f0r-libc++-5.0.2/lib --extra-include-dirs=/nix/store/hgqs9r48niq50xzvgnz7prbykizpy4mk-libc++abi-5.0.2/include --extra-lib-dirs=/nix/store/hgqs9r48niq50xzvgnz7prbykizpy4mk-libc++abi-5.0.2/lib --extra-include-dirs=/nix/store/1sh5ry0k291fx2sbn9p0611v7cc45xpv-compiler-rt-5.0.2-dev/include --extra-lib-dirs=/nix/store/r6aijfn3pi3k11rddrw9531pwglhrblr-compiler-rt-5.0.2/lib --extra-lib-dirs=/nix/store/0lqb3vjib31xyr8iadc8rib9bpl8mf5m-ncurses-6.1-20181027/lib --extra-lib-dirs=/nix/store/0jn6j8ya9zffqd427rjhalhrfqcldalf-gmp-6.1.2/lib --extra-include-dirs=/nix/store/r0wvw1pk9sdylb308zn4hp5j0r6v6ak6-libiconv-osx-10.11.6/include --extra-lib-dirs=/nix/store/r0wvw1pk9sdylb308zn4hp5j0r6v6ak6-libiconv-osx-10.11.6/lib --extra-framework-dirs=/nix/store/mnr82qqf4pkwbvzpvkzp9lcxb6f0b456-swift-corefoundation/Library/Frameworks
    Using Parsec parser
    Configuring a-0.1.0.0...
    Dependency base -any: using base-4.12.0.0
    Source component graph: component lib
    Configured component graph:
        component a-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1 include base-4.12.0.0
    Linked component graph:
        unit a-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1
            include base-4.12.0.0
            A=a-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1:A
    Ready component graph:
        definite a-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1 depends base-4.12.0.0
    Using Cabal-2.4.0.1 compiled by ghc-8.6
    Using compiler: ghc-8.6.3
    Using install prefix: /nix/store/q3npinbdm45vnnly5cn8vpd9r32k3h6l-a-0.1.0.0
    Executables installed in:
    /nix/store/q3npinbdm45vnnly5cn8vpd9r32k3h6l-a-0.1.0.0/bin
    Libraries installed in:
    /nix/store/q3npinbdm45vnnly5cn8vpd9r32k3h6l-a-0.1.0.0/lib/ghc-8.6.3/x86_64-osx-ghc-8.6.3/a-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1
    Dynamic Libraries installed in:
    /nix/store/q3npinbdm45vnnly5cn8vpd9r32k3h6l-a-0.1.0.0/lib/ghc-8.6.3/x86_64-osx-ghc-8.6.3
    Private executables installed in:
    /nix/store/q3npinbdm45vnnly5cn8vpd9r32k3h6l-a-0.1.0.0/libexec/x86_64-osx-ghc-8.6.3/a-0.1.0.0
    Data files installed in:
    /nix/store/q3npinbdm45vnnly5cn8vpd9r32k3h6l-a-0.1.0.0/share/x86_64-osx-ghc-8.6.3/a-0.1.0.0
    Documentation installed in:
    /nix/store/hmyd21lrdl02ckz9xisy3d0ijrmf1z53-a-0.1.0.0-doc/share/doc/a-0.1.0.0
    Configuration files installed in:
    /nix/store/q3npinbdm45vnnly5cn8vpd9r32k3h6l-a-0.1.0.0/etc
    No alex found
    Using ar found on system at:
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ar
    No c2hs found
    No cpphs found
    No doctest found
    Using gcc version 4.2.1 given by user at:
    /nix/store/sanxzj0cy1lxrx3xrlm8hmmkyj7mrrm8-clang-wrapper-5.0.2/bin/clang
    Using ghc version 8.6.3 found on system at:
    /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3/bin/ghc
    Using ghc-pkg version 8.6.3 found on system at:
    /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3/bin/ghc-pkg
    No ghcjs found
    No ghcjs-pkg found
    No greencard found
    Using haddock version 2.22.0 found on system at:
    /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3/bin/haddock
    No happy found
    Using haskell-suite found on system at: haskell-suite-dummy-location
    Using haskell-suite-pkg found on system at: haskell-suite-pkg-dummy-location
    No hmake found
    Using hpc version 0.67 found on system at:
    /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3/bin/hpc
    Using hsc2hs version 0.68.5 found on system at:
    /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3/bin/hsc2hs
    Using hscolour version 1.24 found on system at:
    /nix/store/9d0sbq87ji5h5f4mzi4s4amzs8awdamx-hscolour-1.24.4/bin/HsColour
    No jhc found
    Using ld found on system at:
    /nix/store/4nv4a83a6x536wcci0q15wp5vgii1x7v-cctools-binutils-darwin-wrapper/bin/ld
    No pkg-config found
    Using runghc version 8.6.3 found on system at:
    /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3/bin/runghc
    Using strip found on system at:
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/strip
    Using tar found on system at:
    /nix/store/yi91x2nsi06h3n5snq6i7q301cc7fzvy-gnutar-1.31/bin/tar
    No uhc found
    building
    Preprocessing library for a-0.1.0.0..
    Building library for a-0.1.0.0..
    [1 of 1] Compiling A                ( A.hs, dist/build/A.o )
    [1 of 1] Compiling A                ( A.hs, dist/build/A.p_o )
    ld: warning: /nix/store/r0wvw1pk9sdylb308zn4hp5j0r6v6ak6-libiconv-osx-10.11.6/lib/libiconv.dylib, ignoring unexpected dylib file
    ld: warning: /nix/store/r0wvw1pk9sdylb308zn4hp5j0r6v6ak6-libiconv-osx-10.11.6/lib/libiconv.dylib, ignoring unexpected dylib file
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(Win32Utils.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(consUtils.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(longlong.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(ProfilerReport.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(OldARMAtomic.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(RtsDllMain.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(ProfilerReportJson.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(LdvProfile.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(RetainerProfile.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(Disassembler.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(Trace.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(Profiling.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(RetainerSet.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(Scav_thr.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(Sanity.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(Evac_thr.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(EventLog.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(elf_util.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(elf_plt_arm.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(elf_got.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(Elf.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(elf_plt_aarch64.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(elf_reloc.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(elf_plt.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(PEi386.o) has no symbols
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ranlib: file: dist/build/libHSa-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1-ghc8.6.3.a(elf_reloc_aarch64.o) has no symbols
    running tests
    Package has no test suites.
    haddockPhase
    Preprocessing library for a-0.1.0.0..
    Running Haddock on library for a-0.1.0.0..
    Warning: --source-* options are ignored when --hyperlinked-source is enabled.
    Haddock coverage:
       0% (  0 /  1) in 'A'
      Missing documentation for:
        Module header
    Documentation created: dist/doc/html/a/index.html, dist/doc/html/a/a.txt
    installing
    Installing library in /nix/store/q3npinbdm45vnnly5cn8vpd9r32k3h6l-a-0.1.0.0/lib/ghc-8.6.3/x86_64-osx-ghc-8.6.3/a-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1
    post-installation fixup
    strip is /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/strip
    stripping (with command strip and flags -S) in /nix/store/q3npinbdm45vnnly5cn8vpd9r32k3h6l-a-0.1.0.0/lib
    patching script interpreter paths in /nix/store/q3npinbdm45vnnly5cn8vpd9r32k3h6l-a-0.1.0.0
    strip is /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/strip
    patching script interpreter paths in /nix/store/hmyd21lrdl02ckz9xisy3d0ijrmf1z53-a-0.1.0.0-doc
    building '/nix/store/w136ni99zv0vny12wx4p10wlycv1alap-b-0.1.0.0.drv'...
    setupCompilerEnvironmentPhase
    Build with /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3.
    unpacking sources
    unpacking source archive /nix/store/548px5inz9rym3n77x8gbw4m0r3lhsid-b
    source root is b
    patching sources
    compileBuildDriverPhase
    setupCompileFlags: -package-db=/private/tmp/nix-build-b-0.1.0.0.drv-0/setup-package.conf.d -j1 -threaded
    [1 of 1] Compiling Main             ( /nix/store/4mdp8nhyfddh7bllbi7xszz7k9955n79-Setup.hs, /private/tmp/nix-build-b-0.1.0.0.drv-0/Main.o )
    Linking Setup ...
    configuring
    configureFlags: --verbose --prefix=/nix/store/zj9nq11n2zvdyp7dhrahanmals1dp91k-b-0.1.0.0 --libdir=$prefix/lib/$compiler --libsubdir=$abi/$libname --docdir=/nix/store/fzgfmw5d259x958j8ij4ribxkp0p46fp-b-0.1.0.0-doc/share/doc/b-0.1.0.0 --with-gcc=clang --package-db=/private/tmp/nix-build-b-0.1.0.0.drv-0/package.conf.d --ghc-option=-j1 --disable-split-objs --enable-library-profiling --profiling-detail=exported-functions --disable-profiling --enable-shared --disable-coverage --enable-static --disable-executable-dynamic --enable-tests --disable-benchmarks --enable-library-vanilla --enable-library-for-ghci --extra-include-dirs=/nix/store/jv40yw2ny28nnpbf860aaqq1dhga0f0r-libc++-5.0.2/include --extra-lib-dirs=/nix/store/jv40yw2ny28nnpbf860aaqq1dhga0f0r-libc++-5.0.2/lib --extra-include-dirs=/nix/store/hgqs9r48niq50xzvgnz7prbykizpy4mk-libc++abi-5.0.2/include --extra-lib-dirs=/nix/store/hgqs9r48niq50xzvgnz7prbykizpy4mk-libc++abi-5.0.2/lib --extra-include-dirs=/nix/store/1sh5ry0k291fx2sbn9p0611v7cc45xpv-compiler-rt-5.0.2-dev/include --extra-lib-dirs=/nix/store/r6aijfn3pi3k11rddrw9531pwglhrblr-compiler-rt-5.0.2/lib --extra-lib-dirs=/nix/store/0lqb3vjib31xyr8iadc8rib9bpl8mf5m-ncurses-6.1-20181027/lib --extra-lib-dirs=/nix/store/0jn6j8ya9zffqd427rjhalhrfqcldalf-gmp-6.1.2/lib --extra-include-dirs=/nix/store/r0wvw1pk9sdylb308zn4hp5j0r6v6ak6-libiconv-osx-10.11.6/include --extra-lib-dirs=/nix/store/r0wvw1pk9sdylb308zn4hp5j0r6v6ak6-libiconv-osx-10.11.6/lib --extra-framework-dirs=/nix/store/mnr82qqf4pkwbvzpvkzp9lcxb6f0b456-swift-corefoundation/Library/Frameworks
    Using Parsec parser
    Configuring b-0.1.0.0...
    Dependency a -any: using a-0.1.0.0
    Dependency base -any: using base-4.12.0.0
    Source component graph: component lib
    Configured component graph:
        component b-0.1.0.0-1072cnXtut6ENJ494A3pWo
            include a-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1
            include base-4.12.0.0
    Linked component graph:
        unit b-0.1.0.0-1072cnXtut6ENJ494A3pWo
            include a-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1
            include base-4.12.0.0
            B=b-0.1.0.0-1072cnXtut6ENJ494A3pWo:B
    Ready component graph:
        definite b-0.1.0.0-1072cnXtut6ENJ494A3pWo
            depends a-0.1.0.0-CQnIe1qPUVV66BMgXSBVV1
            depends base-4.12.0.0
    Using Cabal-2.4.0.1 compiled by ghc-8.6
    Using compiler: ghc-8.6.3
    Using install prefix: /nix/store/zj9nq11n2zvdyp7dhrahanmals1dp91k-b-0.1.0.0
    Executables installed in:
    /nix/store/zj9nq11n2zvdyp7dhrahanmals1dp91k-b-0.1.0.0/bin
    Libraries installed in:
    /nix/store/zj9nq11n2zvdyp7dhrahanmals1dp91k-b-0.1.0.0/lib/ghc-8.6.3/x86_64-osx-ghc-8.6.3/b-0.1.0.0-1072cnXtut6ENJ494A3pWo
    Dynamic Libraries installed in:
    /nix/store/zj9nq11n2zvdyp7dhrahanmals1dp91k-b-0.1.0.0/lib/ghc-8.6.3/x86_64-osx-ghc-8.6.3
    Private executables installed in:
    /nix/store/zj9nq11n2zvdyp7dhrahanmals1dp91k-b-0.1.0.0/libexec/x86_64-osx-ghc-8.6.3/b-0.1.0.0
    Data files installed in:
    /nix/store/zj9nq11n2zvdyp7dhrahanmals1dp91k-b-0.1.0.0/share/x86_64-osx-ghc-8.6.3/b-0.1.0.0
    Documentation installed in:
    /nix/store/fzgfmw5d259x958j8ij4ribxkp0p46fp-b-0.1.0.0-doc/share/doc/b-0.1.0.0
    Configuration files installed in:
    /nix/store/zj9nq11n2zvdyp7dhrahanmals1dp91k-b-0.1.0.0/etc
    No alex found
    Using ar found on system at:
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/ar
    No c2hs found
    No cpphs found
    No doctest found
    Using gcc version 4.2.1 given by user at:
    /nix/store/sanxzj0cy1lxrx3xrlm8hmmkyj7mrrm8-clang-wrapper-5.0.2/bin/clang
    Using ghc version 8.6.3 found on system at:
    /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3/bin/ghc
    Using ghc-pkg version 8.6.3 found on system at:
    /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3/bin/ghc-pkg
    No ghcjs found
    No ghcjs-pkg found
    No greencard found
    Using haddock version 2.22.0 found on system at:
    /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3/bin/haddock
    No happy found
    Using haskell-suite found on system at: haskell-suite-dummy-location
    Using haskell-suite-pkg found on system at: haskell-suite-pkg-dummy-location
    No hmake found
    Using hpc version 0.67 found on system at:
    /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3/bin/hpc
    Using hsc2hs version 0.68.5 found on system at:
    /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3/bin/hsc2hs
    Using hscolour version 1.24 found on system at:
    /nix/store/9d0sbq87ji5h5f4mzi4s4amzs8awdamx-hscolour-1.24.4/bin/HsColour
    No jhc found
    Using ld found on system at:
    /nix/store/4nv4a83a6x536wcci0q15wp5vgii1x7v-cctools-binutils-darwin-wrapper/bin/ld
    No pkg-config found
    Using runghc version 8.6.3 found on system at:
    /nix/store/r348h4r4nsmc534239cgq7m51kyyzzrl-ghc-8.6.3/bin/runghc
    Using strip found on system at:
    /nix/store/6fxfcpcb1jlgzkvkdgzja3rkm46200kd-cctools-binutils-darwin/bin/strip
    Using tar found on system at:
    /nix/store/yi91x2nsi06h3n5snq6i7q301cc7fzvy-gnutar-1.31/bin/tar
    No uhc found
    building
    Preprocessing library for b-0.1.0.0..
    Building library for b-0.1.0.0..
    [1 of 1] Compiling B                ( B.hs, dist/build/B.o )
    [1 of 1] Compiling B                ( B.hs, dist/build/B.p_o )
    ld: warning: /nix/store/r0wvw1pk9sdylb308zn4hp5j0r6v6ak6-libiconv-osx-10.11.6/lib/libiconv.dylib, ignoring unexpected dylib file
    ld: warning: /nix/store/r0wvw1pk9sdylb308zn4hp5j0r6v6ak6-libiconv-osx-10.11.6/lib/libiconv.dylib, ignoring unexpected dylib file
    ghc: panic! (the 'impossible' happened)
      (GHC version 8.6.3 for x86_64-apple-darwin):
            Data.Binary.Get.runGet at position 8: Invalid magic number "INPUT(-l"
    CallStack (from HasCallStack):
      error, called at libraries/binary/src/Data/Binary/Get.hs:351:5 in binary-0.8.6.0:Data.Binary.Get

    Please report this as a GHC bug:  http://www.haskell.org/ghc/reportabug

    builder for '/nix/store/w136ni99zv0vny12wx4p10wlycv1alap-b-0.1.0.0.drv' failed with exit code 1
    error: build of '/nix/store/w136ni99zv0vny12wx4p10wlycv1alap-b-0.1.0.0.drv' failed