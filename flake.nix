{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [ ];
      name = "hello";
      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
        config.allowBroken = true;
        config.cudaSupport = true;
      };
      
      opencvCustom = pkgs.opencv.override {
        enableBlas = true;
        enableContrib = true;
        enableCublas = true;
        enableCuda = true;
        enableCudnn = true;
        enableEigen = true;
        enableFfmpeg = true;
        enableIpp = true;
        enableTbb = true;
      };

      date-cpp = pkgs.stdenv.mkDerivation {
        name = "date";
        src = pkgs.fetchFromGitHub {
          owner = "HowardHinnant";
          repo = "date";
          rev = "v3.0.1";
          sha256 = "sha256-ZSjeJKAcT7mPym/4ViDvIR9nFMQEBCSUtPEuMO27Z+I=";
        };

        nativeBuildInputs = with pkgs; [ cmake ];
      };
      
      # Programs used at build time.
      nativeBuildInputs = with pkgs; [ 
        cmake 
        fish 
        gcc 
        #jetbrains.clion 
        jq 
        ninja 
        lesspipe
        which
        pkg-config 
      ];

      # Programs used at runtime.
      buildInputs = with pkgs; [ 
        backward-cpp
        boost 
        clipp
        ctre 
        cudatoolkit 
        #cudaPackages.tensorrt
        date-cpp
        fmt
        libsForQt5.full 
        python39 
        opencvCustom
        sdbus-cpp 
        zmqpp
      ];

      src = ./src;
      
      bin = pkgs.stdenv.mkDerivation {
        inherit nativeBuildInputs buildInputs name src;
        preBuild = ''
          export CUDA_PATH="${pkgs.cudatoolkit}"
        '';
      };
      
      dockerImage = pkgs.dockerTools.buildLayeredImage {
        inherit name;
        tag = "latest";
        contents = [ bin ];
        config = {
          Cmd = [ "${bin}/bin/hello" ];
        };
      };

    in
    {
      devShells.default = with pkgs; mkShell {
        inherit  nativeBuildInputs;
        buildInputs = buildInputs ++ (with pkgs; [ dive ]);
      };
      
      packages = {
        inherit bin dockerImage;
        default = bin;
      };
    }
  );
}