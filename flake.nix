{
  description = "Flake for Pharo-EDA-Tools";

  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    rydnr-nix-flakes-pharo-vm = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:rydnr/nix-flakes/pharo-vm-12.0.1519.4?dir=pharo-vm";
    };
    rydnr-pharo-eda-common = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rydnr-nix-flakes-pharo-vm.follows = "rydnr-nix-flakes-pharo-vm";
      url = "github:rydnr/pharo-eda-common/0.1.2";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        org = "rydnr";
        repo = "pharo-eda-tools";
        pname = "${repo}";
        tag = "0.1.0";
        baseline = "PharoEDATools";
        pkgs = import nixpkgs { inherit system; };
        description = "Additional tools for PharoEDA.";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/rydnr/pharo-eda-tools";
        maintainers = with pkgs.lib.maintainers; [ ];
        nixpkgsVersion = builtins.readFile "${nixpkgs}/.version";
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixpkgs-${nixpkgsVersion}";
        shared = import ./nix/shared.nix;
        pharo-eda-tools-for = { bootstrap-image-name, bootstrap-image-sha256, bootstrap-image-url, pharo-eda-common, pharo-vm }:
          let
            bootstrap-image = pkgs.fetchurl {
              url = bootstrap-image-url;
              sha256 = bootstrap-image-sha256;
            };
            src = ./src;
            pharo-spec-spec = pkgs.fetchgit {
              url = "https://github.com/pharo-spec/spec";
              rev = "790149f2a82e3bc5bf8e3e847468396fabe97cfd";
              sha256 = "sha256-D2nrJAaVe1768nFU7efSIJhnzCexpPCgjOaWMgDP1AY=";
              leaveDotGit = true;
            };
          in pkgs.stdenv.mkDerivation (finalAttrs: {
            version = tag;
            inherit pname src;

            strictDeps = true;

            buildInputs = with pkgs; [
              pharo-eda-common
            ];

            nativeBuildInputs = with pkgs; [
              pharo-vm
              pkgs.unzip
            ];

            unpackPhase = ''
              unzip -o ${bootstrap-image} -d image
              cp -r ${src} src
              mkdir -p $out/share/src/${pname}
              cp -r ${pharo-spec-spec}/src $out/share/src/spec
            '';

            configurePhase = ''
              runHook preConfigure

              substituteInPlace src/BaselineOf${baseline}/BaselineOf${baseline}.class.st \
                --replace-fail "github://rydnr/pharo-eda-common:main" "tonel://${pharo-eda-common}/share/src/pharo-eda-common" \
                --replace-fail "github://pharo-spec/Spec:Pharo10" "filetree://$out/share/src/spec" \

              # load baseline
              ${pharo-vm}/bin/pharo image/${bootstrap-image-name} eval --save "EpMonitor current disable. NonInteractiveTranscript stdout install. [ Metacello new repository: 'tonel://$PWD/src'; baseline: '${baseline}'; onConflictUseLoaded; load ] ensure: [ EpMonitor current enable ]"

              runHook postConfigure
            '';

            buildPhase = ''
              runHook preBuild

              ${pharo-vm}/bin/pharo image/${bootstrap-image-name} save "${pname}"

              # customize image

              mkdir dist
              mv image/${pname}.* dist/

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p $out
              cp -r ${pharo-vm}/bin $out
              cp -r ${pharo-vm}/lib $out
              cp -r dist/* $out/
              cp image/*.sources $out/
              pushd src
              cp -r * $out/share/src/${pname}/
              pushd $out/share/src/${pname}
              ${pkgs.zip}/bin/zip -r $out/share/src.zip .
              popd
              pushd $out/share/src/spec
              ${pkgs.zip}/bin/zip -r $out/share/spec.zip .
              popd
              popd

              runHook postInstall
             '';

            meta = {
              changelog = "https://github.com/rydnr/pharo-eda-tools/releases/";
              longDescription = ''
                    Additional tools for PharoEDA.
              '';
              inherit description homepage license maintainers;
              mainProgram = "pharo";
              platforms = pkgs.lib.platforms.linux;
            };
        });
      in rec {
        defaultPackage = packages.default;
        devShells = rec {
          default = pharo-eda-tools-12;
          pharo-eda-tools-12 = shared.devShell-for {
            package = packages.pharo-eda-tools-12;
            inherit org pkgs repo tag;
            nixpkgs-release = nixpkgsRelease;
          };
        };
        packages = rec {
          default = pharo-eda-tools-12;
          pharo-eda-tools-12 = pharo-eda-tools-for rec {
            bootstrap-image-url = rydnr-nix-flakes-pharo-vm.resources.${system}.bootstrap-image-url;
            bootstrap-image-sha256 = rydnr-nix-flakes-pharo-vm.resources.${system}.bootstrap-image-sha256;
            bootstrap-image-name = rydnr-nix-flakes-pharo-vm.resources.${system}.bootstrap-image-name;
            pharo-eda-common = rydnr-pharo-eda-common.packages.${system}.pharo-eda-common-12;
            pharo-vm = rydnr-nix-flakes-pharo-vm.packages.${system}.pharo-vm;
          };
        };
      });
}
