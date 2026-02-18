{ ... }:

{
  # MOSH: Mobile Shell for flaky connections
  # This enables the server and automatically opens UDP ports 60000-61000 in the firewall.
  programs.mosh.enable = true;
}
