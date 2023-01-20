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
      packages = {
        hobot-cicd = pkgs.dockerTools.buildImage {
          name = "hobot-cicd";
          tag = "latest";

          copyToRoot = pkgs.buildEnv {
            name = "root-environment";
            paths = with pkgs; [
              bash
              git
              # iputils
              # coreutils
              # findutils
              # fd
              # openssl
              # openssh
              # curl
              # clang-format

              # (python3.withPackages (pyPkgs: with pyPkgs; [
              #   alf-cpu

              #   # Utils
              #   numpy-quaternion

              #   # Simulators
              #   mujoco-pybind
              #   dm-control

              #   # Deveopment Tools
              #   yapf
              #   pylint
              #   pre-commit
              ]))
            ];
            pathsToLink = [ "/bin" ];
          };

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
