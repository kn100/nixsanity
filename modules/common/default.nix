{ pkgs, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
  };

  time.timeZone = "Canada/Eastern";

  services.xserver.xkb.layout = "us"; # Common environment settings

  environment.systemPackages = with pkgs; [
    vim
    htop
    curl
    git
    tree
  ];

  # Deployment & Admin Setup
  security.sudo.wheelNeedsPassword = false;

  programs.git = {
    enable = true;
    config = {
      user.name = "kn100";
      user.email = "kn100@kn100.me";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
