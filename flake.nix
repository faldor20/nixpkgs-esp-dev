{
  description = "ESP8266/ESP32 development tools";

  inputs = {
    # nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "nixpkgs/22.11";
    # nixpkgs-stable.url="nixpkgs/22.11";
    flake-utils.url = "github:numtide/flake-utils";

    mach-nix.url = "mach-nix/3.5.0";  };

  outputs = { self, nixpkgs,mach-nix, 
   # nixpkgs-stable,
   flake-utils }: 
  {
    overlay = import ./overlay.nix{mach-nix= mach-nix.lib."x86_64-linux";};
  } // flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      # stable=import nixpkgs-stable;
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlay 
      # (self: super: { 
      #   python39Packages.bitstring = stable.python39Packages.bitstring;
      #   python310Packages.bitstring = stable.python310Packages.bitstring;
      #  })
        ]; };
    in
    {
      packages = {
        inherit (pkgs)
          gcc-riscv32-esp32c3-elf-bin
          gcc-xtensa-esp32-elf-bin
          gcc-xtensa-esp32s2-elf-bin
          gcc-xtensa-esp32s3-elf-bin
          openocd-esp32-bin
          esp-idf

          gcc-xtensa-lx106-elf-bin
          crosstool-ng-xtensa
          gcc-xtensa-lx106-elf;
      };
    });
}

