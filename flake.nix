{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.11";
    kapack.url = "github:oar-team/nur-kapack/add_aarch64_darwin_system";
  };

  outputs = { self, nixpkgs, kapack }:
    let
      #system = "x86_64-linux";
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
      #kap = kapack.packages.${system};
      sg = pkgs.simgrid.overrideAttrs (finalAttrs: previousAttrs: {
        doCheck = false;
        meta.broken = false;
      });
      batsim = kapack.packages.${system}.batsim.override { simgrid = sg; };
    in
    {

      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # 
            julia-bin
            batsim
            #kap.batsched
            #kap.batexpe
            zeromq
          ];
        };
      };

    };
}
