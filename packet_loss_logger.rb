require 'net/ping'

class PacketLossLogger

  attr_reader :host, :packet_size, :time_end

  def run(params)
    error = 'Wrong format! pll.rb [host_name] [packet_size_in_bytes] [runtime format: 1s, 1m , 1h or 1d]'
    raise error if params_not_valid?(params)
    set_logger_settings(params)
    set_ping_settings
    set_save_settings
    ping_log_inform
    save_results
    inform
  end

  def params_not_valid?(params)
    !(params.join(' ') =~ /\A([a-z0-9_-]+\.[a-z]+) +(\d+) +(\d+[s|m|h|d])\z/)
  end

  def set_logger_settings(params)
    @host, packet_size, runtime = params
    @packet_size = packet_size.to_i
      runtime_duration = runtime[0..-2].to_i
      runtime_units = runtime[-1]
      runtime_units = case runtime_units
                        when 'm' then 60
                        when 'h' then 3600
                        when 'd' then 86400
                        else 1
                      end
      runtime = runtime_duration*runtime_units
      @time_start = Time.now
      @time_end = @time_start+runtime
      @the_worst_time = @total_fails = 0
    self
  end

  def set_ping_settings
    @icmp = Net::Ping::ICMP.new(@host)
    @icmp.data_size = @packet_size
  end

  def set_save_settings
    location = File.expand_path(File.dirname(__FILE__))
    @log = File.new("#{location}/log.txt", 'a+')
  end

  def ping_log_inform
    loop do
      time_current = Time.now
        if @icmp.ping
          duration = (@icmp.duration*1000).round(1)
            puts "[#{@host}] replied in #{duration} ms"
          @the_worst_time = duration if duration > @the_worst_time
        else
          File.open(@log, 'a+') { |data| data.puts "#{time_current} request timeout with [#{host}]" }
          @total_fails += 1
        end
        sleep 1
      break if time_current >= @time_end
    end
  end

  def save_results
    File.open(@log, 'a+') { |data| data.puts "#### Ping to [#{@host}], started at: #{@time_start}, finished at: #{@time_end}. Total timeouts: #{@total_fails}. The worst time is #{@the_worst_time} ms. ####" }
  end

  def inform
    puts "#{IO.readlines(@log).last[0..-2]}"
    puts "For more details see the log: #{File.expand_path(@log, __FILE__)}"
  end

end