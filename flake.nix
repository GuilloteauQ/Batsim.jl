{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    kapack.url = "github:oar-team/nur-kapack";
  };

  outputs = { self, nixpkgs, kapack }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      kap = kapack.packages.${system};
    in
    {

      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # 
            julia-bin
            kap.batsim
            zeromq
          ];
        };
      };

    };
}
