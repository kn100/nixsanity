{ ... }:

{
  # Suggestions for improving network throughput:
  #
  # 1. Use an interface with hardware offloading (e.g., Intel X540/X710, Mellanox ConnectX).
  #    Ensure that features like TSO (TCP Segmentation Offload), GSO (Generic Segmentation
  #    Offload), and GRO (Generic Receive Offload) are enabled. These are typically enabled
  #    by default if the NIC supports them, but can be verified with `ethtool -k <interface>`.
  #
  # 2. To optimize for a 500 Mbps connection (especially over higher latency links),
  #    we increase the OS TCP buffer sizes.
  #    Calculation: 500 Mbps = 62.5 MB/s. At 100ms latency, BDP is ~6.25MB.
  #    We set the max buffers to ~8MB (8388608 bytes) for good measure.
  #
  # 3. Testing and optimizing MTU for Tailscale:
  #    Tailscale uses an MTU of 1280 by default. To check if this MTU is optimal
  #    or if packets are being fragmented over your connection, you can test with:
  #      ping -M do -s 1252 <tailscale_ip>
  #    The `-s 1252` specifies payload size (1280 TS MTU - 28 bytes IP+ICMP headers).
  #    The `-M do` flag prohibits fragmentation. If you see "Message too long",
  #    your path MTU might be lower. If it succeeds, the MTU is fine. You can gradually
  #    increase `-s` up to your physical interface's limits (usually `-s 1472`) to see
  #    if larger MTUs are possible! We enable tcp_mtu_probing below to allow the kernel
  #    to dynamically adapt for TCP traffic automatically anyway.

  # Enable BBR TCP congestion control algorithm.
  # BBR achieves higher bandwidths and lower latencies than Cubic, especially
  # on high-speed long-distance links or links with small amounts of packet loss.
  boot.kernel.sysctl = {
    # Increase to 16MB for better high-latency headroom
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";

    # Keep these - they are doing good work
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # Helps with Tailscale/VPN fragmentation
    "net.ipv4.tcp_slow_start_after_idle" = 0;
  };
}
