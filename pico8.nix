with (import <nixpkgs> {});
stdenv.mkDerivation rec {
  name = "pico-8";
  src = ./pico-8_0.2.1b_amd64.zip;
  buildInputs = [unzip patchelf];

  inherit SDL2;

  LD_LIBRARY_PATH =
    let sdl_load_path = with xorg; [ libX11
                                     libXext
                                     libXcursor
                                     libXinerama
                                     libXi
                                     libXrandr
                                     libXScrnSaver
                                     libXxf86vm
                                     libxcb
                                     libXrender
                                     libXfixes
                                     libXau
                                     libXdmcp
                                     udev
                                   ];
    in "${lib.makeLibraryPath sdl_load_path}";


  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir $out
    cp pico-8/* $out
    mkdir $out/bin
    echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH} $out/pico8" > $out/bin/pico8
    chmod 555 $out/bin/pico8
  '';

  preFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/pico8

    patchelf \
      --replace-needed \
       libSDL2-2.0.so.0 $SDL2/lib/libSDL2-2.0.so.0 \
       $out/pico8_dyn
  '';
}
