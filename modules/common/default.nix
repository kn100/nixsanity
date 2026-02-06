{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Canada/Eastern";

  services.xserver.xkb.layout = "us";

  environment.systemPackages = with pkgs; [
    vim
    htop
    curl
    git
    tree
  ];

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
