# {
#   description = "A very basic flake";
# 
#   outputs = { self, nixpkgs }: {
# 
#     packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
# 
#     defaultPackage.x86_64-linux = self.packages.x86_64-linux.hello;
# 
#   };
# }

{
  description = "Your flake using poetry2nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.utils.url = "github:numtide/flake-utils";
  inputs.poetry2nix-src.url = "github:nix-community/poetry2nix";

  outputs = { nixpkgs, utils, poetry2nix-src, self }: utils.lib.eachDefaultSystem (system:
    let

      pkgs = import nixpkgs { inherit system; overlays = [ poetry2nix-src.overlay ]; };

    in
    {
      defaultPackage = pkgs.poetry2nix.mkPoetryApplication {
        projectDir = ./.;
      };

      devShell = pkgs.mkShell {

        # Add anything in here if you want it to run when we run `nix develop`.
        shellHook = ''
          echo "Updating .vscode/settings.json to have the correct python interpreter."
          jq ".[\"python.pythonPath\"]=\"$(which python)\"" .vscode/settings.json
          '';
        buildInputs = with pkgs; [
          # Additional dev packages list here.
          nixpkgs-fmt
          (pkgs.poetry2nix.mkPoetryEnv {
            projectDir = ./.;

            editablePackageSources = {
              my-app = ./src;
            };
          })
        ];
      };

    });
}
