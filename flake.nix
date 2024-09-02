{
  inputs = {
    # You can override nixpkgs to use the latest set of node packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    systems,
    nixpkgs,
    ...
  } @ inputs: let
    eachSystem = f:
      nixpkgs.lib.genAttrs (import systems) (
        system:
          f nixpkgs.legacyPackages.${system}
      );
  in {
    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        buildInputs = [
          pkgs.nodejs
          pkgs.npm-check
          pkgs.nodePackages.typescript
          pkgs.nodePackages.typescript-language-server
          pkgs.nodePackages.svelte-language-server
          pkgs.nodePackages.svelte-check
          pkgs.vscode-langservers-extracted
          pkgs.gnumake
          pkgs.gnutar
          pkgs.zip
          pkgs.awscli          
        ];
      };
    });
  };
}
