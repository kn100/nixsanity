{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    git
    nixos-rebuild
    yj
    age
    sops
  ];

  shellHook = ''
    echo "--- Nixsanity Development Shell ---"
  '';
}
