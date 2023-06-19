{
  description = "A flake for a pybatsim example";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    nur-kapack = {
      url = "github:oar-team/nur-kapack";
      # flake = false;
    };
  };

  outputs = { self, nixpkgs, nur-kapack}:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # kapack = import nur-kapack {inherit pkgs; };
      kapack = nur-kapack.packages.${system};



    in {
      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs =
            [
            # pybatsim_pkgs.pybatsim-core
            (kapack.pybatsim-core-400.overrideAttrs (old: {
              src = "${pkgs.fetchFromGitLab {
                domain = "gitlab.inria.fr";
                owner = "batsim";
                repo = "pybatsim";
                rev = "eacd15129e567f4f0c90cd1559aed06ace2eddc5";
                sha256 = "sha256-97NqxWc54zsUt8jO9jd+i8NnLLx9vTgPNzQyY7XG1sU=";
              }}/${old.pname}";
            }))
            kapack.batsim
            kapack.batexpe
            kapack.batsched
            pkgs.julia-bin ];
          shellHook = ''
            echo "batsim: $(batsim --version)"
            echo "simgrid: $(batsim --simgrid-version)"
            echo "robin: $(robin --version)"
            echo "pybatsim: $(pybatsim --version)"
          '';
        };
      };
    };
}

