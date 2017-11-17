=begin
ICMP Packet Loss Logger by Vladislav Trotsenko.

Simple packet loss logger build with using net/ping gem.
(https://github.com/djberg96/net-ping).

I have found the main idea for writing this script when I
needed to log loss packets on CentOS 6.5 server.

I tried to use in bash ping (from iputils), like this code:
# ping -D -O -s 1000 myhost | grep 'no answer', but ping from
iputils(20071127-24) on CentsOS doesn't know O-key(.

Use options for run this script with superadmin permissions,
like example below:

# sudo ruby pll.rb host.com 1000 20s
=end
require 'net/ping'
  params = ARGF.argv

    if !(params.join(' ') =~ /\A([a-z0-9_-]+\.[a-z]+) +(\d+) +(\d+[s|m|h|d])\z/)
      abort 'Wrong format! pll.rb [host_name] [packet_size_in_bytes] [runtime format: 1s, 1m , 1h or 1d]'
    end

      host, packet_size, runtime = params
        packet_size, runtime_duration, runtime_units = packet_size.to_i, runtime[0..-2].to_i, runtime[-1]
          runtime_units = case runtime_units
            when 'm' then 60
            when 'h' then 3600
            when 'd' then 86400
            else 1
          end
        runtime = runtime_duration*runtime_units
      time_start, time_current = Time.now
    time_end = time_start+runtime

  location = File.expand_path(File.dirname(__FILE__))
    log = File.new("#{location}/log.txt", 'a+')
      icmp = Net::Ping::ICMP.new(host)
    icmp.data_size = packet_size
  the_worst_time, total_fails = 0, 0

    loop do
      time_current = Time.now
        if icmp.ping
          duration = (icmp.duration*1000).round(1)
            puts "[#{host}] replied in #{duration} ms"
          the_worst_time = duration if duration > the_worst_time
        else
          File.open(log, 'a+') { |data| data.puts "#{time_current} request timeout with [#{host}]" }
          total_fails += 1
        end
        sleep 1
      break if time_current >= time_end
    end
    
    File.open(log, 'a+') { |data| data.puts "#### Ping to [#{host}], started at: #{time_start}, finished at: #{time_end}. Total timeouts: #{total_fails}. The worst time is #{the_worst_time} ms. ####" }
  puts "#{IO.readlines(log).last[0..-2]}"
puts "For more details see the log: #{File.expand_path(log, __FILE__)}"