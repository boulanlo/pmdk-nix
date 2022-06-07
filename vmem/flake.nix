{
  description = "libvmem and libvmmalloc: malloc-like volatile allocations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/21.11";
  };
  
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      vmem-version = "1.8";
      
      src = pkgs.fetchFromGitHub {
        owner = "pmem";
        repo = "vmem";
        rev = "${vmem-version}";
        sha256 = "Y0IadDSk5/evSmZwi+tddZo1DQLRrr9/vYO3xl2bQJU=";
      };
      
    in
      {
        packages."${system}" = {
          vmem = with pkgs;
            stdenv.mkDerivation {
              name = "vmem";

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
                make install prefix=$out
              '';
            };
        };

        defaultPackage."${system}" = self.packages."${system}".vmem;
      };
}
