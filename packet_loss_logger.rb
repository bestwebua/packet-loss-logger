require 'net/ping/icmp'

class PacketLossLogger
  attr_reader :host, :packet_size, :runtime, :time_end, :icmp, :log
  attr_accessor :the_worst_time, :total_fails

  def run(params)
    raise message[0] unless params_valid?(params)
    set_logger_settings(params, runtime_calculation(params))
    set_ping_settings(host, packet_size)
    set_save_settings
    ping_log_inform(icmp, host, time_end, log)
    save_results(log)
    informer(log)
  end

  def params_valid?(params)
    params.is_a?(Array) && !!(params.join(' ') =~ /\A([a-z0-9_-]+\.[a-z]+) +(\d+) +(\d+[s|m|h|d])\z/)
  end

  def runtime_calculation(params)
    runtime = params[-1]
    runtime_duration = runtime[0..-2].to_i
    runtime_units = runtime[-1]
    runtime_units = case runtime_units
                      when 'm' then 60
                      when 'h' then 3600
                      when 'd' then 86_400
                      else 1
                    end
    runtime_duration * runtime_units
  end

  def set_logger_settings(params, runtime)
    @host, @packet_size, @runtime = params[0], params[1].to_i, runtime
    @time_start = Time.now
    @time_end = @time_start + self.runtime
    @the_worst_time = @total_fails = 0
    self
  end

  def set_ping_settings(host, packet_size)
    @icmp = Net::Ping::ICMP.new(host)
    @icmp.data_size = packet_size
    @icmp.class
  end

  def set_save_settings
    location = File.expand_path(__dir__)
    @log = File.new("#{location}/log.txt", 'a+')
  end

  def ping_log_inform(icmp, host, time_end, log)
    loop do
      time_current = Time.now
      if icmp.ping
        duration = (icmp.duration * 1000).round(1)
        puts "[#{host}] replied in #{duration} ms"
        self.the_worst_time = duration if duration > the_worst_time
      else
        File.open(log, 'a+') do |data|
          data.puts "#{time_current} request timeout with [#{host}]"
        end
        self.total_fails += 1
      end
      sleep 1
      break if time_current >= time_end
    end
  end

  def save_results(log)
    File.open(log, 'a+') { |data| data.puts message[1] }
    !File.zero?(log)
  end

  def informer(log)
    return false if File.zero?(log)
    puts IO.readlines(log).last[0..-2]
    puts "#{message[2]} #{File.expand_path(log, __FILE__)}"
  end

  def message
    ['Wrong format! pll.rb [host_name] [packet_size_in_bytes] [runtime format: 1s, 1m, 1h or 1d]',
      "#### Ping to [#{@host}], started at: #{@time_start}, finished at: #{@time_end}. Total timeouts: #{total_fails}. The worst time is #{the_worst_time} ms. ####",
      'For more details see the log:']
  end
end
