{
  description = "SQuent dotfiles — standalone Home Manager configuration (macOS, Linux, WSL)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylux need to match home manager version
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Auto-discovers every .nix file under a directory and imports it as a module
    import-tree.url = "github:vic/import-tree";
  };

  # `self` is always passed by Nix, so the pattern stays open rather than
  # binding an argument nothing here uses (deadnix would flag it).
  outputs =
    {
      nixpkgs,
      home-manager,
      lazyvim,
      stylix,
      import-tree,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      # homeConfigurations are keyed by system only (not username/hostname);
      # home/default.nix resolves username/homeDirectory impurely at
      # activation time so one flake works across machines/users.
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      pkgsBySystem = lib.genAttrs systems (system: import nixpkgs { inherit system; });

      # Builds `attrs` once per supported system, with that system's pkgs.
      forEachSystem = f: lib.mapAttrs (_: pkgs: f pkgs) pkgsBySystem;

      mkHome =
        system: pkgs:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            paletteGenerator = stylix.packages.${system}.palette-generator;
          };
          modules = [
            lazyvim.homeManagerModules.default
            stylix.homeModules.stylix
            (import-tree ./home)
          ];
        };
    in
    {
      homeConfigurations = lib.mapAttrs mkHome pkgsBySystem;

      # `nix fmt` support, via nixfmt-tree (treefmt wrapper so it can format
      # the whole repo in one invocation).
      formatter = forEachSystem (pkgs: pkgs.nixfmt-tree);

      # Everything this repo's own tooling needs (pre-commit hooks, doc
      # generation). Nothing here leaks into the user environment: it is the
      # repo's build-time toolbox, not part of home.packages.
      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = [
            (pkgs.python3.withPackages (ps: [ ps.pyyaml ]))
            pkgs.gomplate
            pkgs.pre-commit
            # docs/extract_packages.py shells out to `mise registry`.
            pkgs.mise
            pkgs.deadnix
            pkgs.gitleaks
          ];
        };
      });

      # `deadnix` and `home-manager`, pinned to this flake's own nixpkgs/
      # home-manager input rather than the caller's flake registry.
      apps = forEachSystem (pkgs: {
        deadnix = {
          type = "app";
          program = "${pkgs.deadnix}/bin/deadnix";
        };
        home-manager = {
          type = "app";
          program = "${
            home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager
          }/bin/home-manager";
        };
      });
    };
}
