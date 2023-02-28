{ pkgs
, buildImage
, buildLayeredIamge
, caCertificates
, usrBinEnv
, binSh
, fakeNss
}:

rec {
  barebone = buildImage {
    name = "barebone";
    tag = "latest";
    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = with pkgs; [
        bashInteractive
        iputils
        coreutils
        findutils

        # Docker Tools
        caCertificates
        usrBinEnv
        binSh
        fakeNss
      ];
      pathsToLink = [ "/bin" ];
    };
  };

  hobotWithCuda = buildImage {
    name = "hobot-cuda";
    tag = "latest";

    fromImage = barebone;

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = with pkgs; [
        (python3.withPackages (pyPkgs: with pyPkgs; [
          alf
          
          # Utils
          numpy-quaternion
          jinja2

          # Simulators
          mujoco-pybind
          dm-control
          python-fcl
        ]))
      ];
      pathsToLink = [ "/bin" ];
    };
  };
}
