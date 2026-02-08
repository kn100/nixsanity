{ config, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.jellyfin = {
    # This environment block ensures FFmpeg knows exactly which driver to use
    # and where to find the OpenCL/VPL runtimes for HDR tone mapping.
    environment = {
      LIBVA_DRIVER_NAME = "iHD";
      # Helps FFmpeg find the Intel Compute Runtime for HDR tone mapping
      OCL_ICD_VENDORS = "${pkgs.intel-compute-runtime}/etc/OpenCL/vendors/intel.icd";
    };

    serviceConfig = {
      ProtectSystem = "full";
      PrivateDevices = false;
      DeviceAllow = [
        "/dev/dri/renderD128"
        "/dev/dri/card0"
      ];

      BindPaths = [
        "/etc/OpenCL/vendors"
      ];
      BindReadOnlyPaths = [
        "/cow/burnable/qbittorrent/downloads/movies"
        "/cow/burnable/qbittorrent/downloads/tv"
      ];
    };
  };

  # This creates the physical directory and the link that FFmpeg looks for
  environment.etc."OpenCL/vendors/intel.icd".source =
    "${pkgs.intel-compute-runtime}/etc/OpenCL/vendors/intel.icd";

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # Primary iHD driver for 11th Gen
      intel-compute-runtime # Required for HDR -> SDR Tone Mapping
      vpl-gpu-rt # Video Processing Library (replaces Media SDK for 11th Gen+)
      intel-gpu-tools # Useful for running 'intel_gpu_top' to verify usage
    ];
  };

  users.users.jellyfin = {
    extraGroups = [
      "video"
      "render"
      "cowaccess"
    ];
  };
}
