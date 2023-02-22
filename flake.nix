{
  description = "Containers for development of General AI Lab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    utils.url = "github:numtide/flake-utils";

    alf-devenv.url = "github:HorizonRobotics/alf-nix-devenv";
    alf-devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs: inputs.utils.lib.eachSystem [
    "x86_64-linux"
  ] (system:
    let pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            inputs.alf-devenv.overlays.hobot
          ];
        };
    in {
      packages = rec {
        ubuntu = pkgs.dockerTools.pullImage {
          imageName = "ubuntu";
          finalImageName = "ubuntu";
          imageDigest = "sha256:27cb6e6ccef575a4698b66f5de06c7ecd61589132d5a91d098f7f3f9285415a9";
          sha256 = "27cb6e6ccef575a4698b66f5de06c7ecd61589132d5a91d098f7f3f9285415a9";
          finalImageTag = "22.04";
          os = "linux";
          arch = "x86_64";
        };
        hobot-cicd = pkgs.dockerTools.buildImage {
          name = "hobot-cicd";
          tag = "latest";
          created = "now";
          fromImage = ubuntu;

          copyToRoot = pkgs.buildEnv {
            name = "root-environment";
            paths = with pkgs; [
              bash
              git
              iputils
              coreutils
              gnugrep
              openssl
              openssh
              curl
              clang-tools
              nodejs

              dockerTools.usrBinEnv
              dockerTools.binSh
              dockerTools.caCertificates
              dockerTools.fakeNss

              (python3.withPackages (pyPkgs: with pyPkgs; [
                alf-cpu

                # Utils
                numpy-quaternion

                # Simulators
                mujoco-pybind
                dm-control

                # Deveopment Tools
                yapf
                pylint
                pre-commit
              ]))
            ];
            pathsToLink = [ "/bin" ];
          };

          runAsRoot = ''
            #!${pkgs.runtimeShell}
            mkdir -p /etc
            touch /etc/os-release
            echo "ID=nixos" >> /etc/os-release
          '';

          config = {
            Cmd = [ "/bin/bash" ];
            Env = [
              "GIT_SSL_CAINFO=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            ];
          };
        };
      };
    });
}
