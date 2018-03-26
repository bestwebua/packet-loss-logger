=begin
ICMP Packet Loss Logger by Vladislav Trotsenko.

Simple packet loss logger build with using net/ping gem.
(https://github.com/djberg96/net-ping).

I have found the main idea for writing this script when I
needed to log loss packets on CentOS 6.5 server.

I tried to use in bash ping (from iputils) code like this:
# ping -D -O -s 1000 myhost | grep 'no answer', but ping from
iputils(20071127-24) on CentsOS doesn't know O-key(.

Use options for run this script with superadmin permissions,
like example below:

# sudo ruby pll.rb host.com 1000 20s
=end

require_relative 'packet_loss_logger'

logger = PacketLossLogger.new
logger.run(ARGF.argv)