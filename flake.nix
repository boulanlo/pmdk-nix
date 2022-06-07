{
  description = "The Persistent Programming development kit.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/21.11";
  };
  
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pmdk-version = "1.12.0";
      
      src = pkgs.fetchFromGitHub {
        owner = "pmem";
        repo = "pmdk";
        rev = "${pmdk-version}";
        sha256 = "0N1pS2Gxp9kVw6A5o+Frb0eMff1VR/ExyAHZUVBVlpU=";
      };
      
    in
      {
        packages."${system}" = {
          pmdk = with pkgs;
            stdenv.mkDerivation {
              name = "pmdk";

              inherit src;

              buildInputs = [
                findutils autoconf pkg-config libndctl pandoc coreutils gnum4 cmake util-linux perl
              ];

              phases = [ "unpackPhase" "preBuild" "buildPhase" "installPhase" ];

              preBuild = ./patch_makefile.sh;
              
              buildPhase = ''
                make EXTRA_CFLAGS="-Wno-error=maybe-uninitialized"
              '';

              installPhase = ''
                mkdir -p $out/
                make install DESTDIR=$out
              '';
            };
        };

        defaultPackage."${system}" = self.packages."${system}".pmdk;
      };
}
